/*SET GLOBAL event_scheduler = ON;*/

 
 
 
 
 
 DROP VIEW IF EXISTS Intervalli;
CREATE VIEW Intervalli as
select  distinct OAC.Centro,I.Ora1,I.Ora2
from OrarioAperturaCentro OAC INNER JOIN IntervalliTempo I ON
     (I.Ora1 >= OAC.OrarioApertura
       AND
       I.Ora1<OAC.OrarioChiusura)
       AND
	  (I.Ora2>OAC.OrarioApertura
       AND
       I.Ora2<=OAC.OrarioChiusura)
order by OAC.Centro,I.Ora1,I.Ora2;


 
 DROP VIEW IF EXISTS AccessiGiorni;
 CREATE VIEW AccessiGiorni AS
 SELECT TrovaGiorno(DataAccesso) AS Giorno,Sala,OrarioAccesso,OrarioUscita
 FROM AccessoSala ;
 
 
 
 DROP VIEW IF EXISTS Corso_Giorni;
 CREATE VIEW Corso_Giorni AS
 SELECT C.CodCorso, A.Giorno
        FROM AccessiGiorni A INNER JOIN Corso C
		ON A.Sala=C.Sala
		WHERE EXISTS (  SELECT *
						FROM CalendarioLezioni CL
						WHERE CL.GiornoSettimana=A.Giorno 
						AND A.OrarioAccesso>=CL.OrarioInizio
						AND CL.CodCorso=C.CodCorso);
                        
 





DROP PROCEDURE IF EXISTS Calcolo_Offerte;
DELIMITER $$
CREATE PROCEDURE Calcolo_Offerte()
BEGIN
 
 DECLARE Clienti_PiscineStandard INT DEFAULT 0;
 DECLARE Clienti_PiscinePersonalizzato INT DEFAULT 0;
 DECLARE FrequenzaPiscine DOUBLE DEFAULT 0.00;
 DECLARE ClientiAree INT DEFAULT 0;
 DECLARE FrequenzaUtilizzoAreeAllestibili DOUBLE DEFAULT 0.00;
 DECLARE MediaFrequentatori DOUBLE DEFAULT 0.00;
 DECLARE ClientiTotali INT DEFAULT 0;
 
 
 
 
 SELECT COUNT(DISTINCT AP.Cliente) INTO Clienti_PiscineStandard   /*VENGONO CONSIDERATI ANCHE I SENZA CONTRATTO*/
 FROM Accesso_Pagato AP LEFT JOIN  Contratto C
  ON C.Cliente=AP.Cliente
   INNER JOIN AbbonamentoStandard AB
    ON C.Tipologia=AB.NomeAbbonamento
      INNER JOIN Piscina P
       ON P.CodPiscina=AP.Sala
 WHERE (AP.DataAccesso NOT BETWEEN C.DataSottoscrizione AND (C.DataSottoscrizione + INTERVAL C.DuratainMesi MONTH)
    OR C.Cliente IS NULL)
    AND (AB.AccessoPiscine=0 OR AB.AccessoPiscine IS NULL);
    
    
    SELECT COUNT(DISTINCT AP.Cliente) INTO Clienti_PiscinePersonalizzato
 FROM Accesso_Pagato AP INNER JOIN  Contratto C
  ON C.Cliente=AP.Cliente
   INNER JOIN AutorizzazionePersonalizzata AB
    ON C.CodContratto=AB.Contratto
      INNER JOIN Piscina P
       ON P.CodPiscina=AP.Sala
 WHERE (AP.DataAccesso NOT BETWEEN C.DataSottoscrizione AND (C.DataSottoscrizione + INTERVAL C.DuratainMesi MONTH)
    OR C.Cliente IS NULL)
    AND ((AB.AccessoPiscine=0 AND AB.Centro=P.Centro) OR AB.AccessoPiscine IS NULL);
    


  SELECT COUNT(*) INTO ClientiTotali
  FROM Cliente;
  
  SET FrequenzaPiscine=((Clienti_PiscineStandard + Clienti_PiscinePersonalizzato)/ClientiTotali) *100;
  
  
  
   
   SELECT COUNT(DISTINCT SA.Cliente) INTO ClientiAree  /* Vengono considerati anche i senza contratto */
 FROM SaldoAreeAllestibiliCliente SA INNER JOIN   Contratto C
    ON SA.Cliente=C.Cliente
 WHERE SA.SaldoMese>0 OR SA.SaldoTotale>0;
 
 SET FrequenzaUtilizzoAreeAllestibili=(ClientiAree/ClientiTotali) * 100;
 
 INSERT INTO MV_Piscine_Aree 
 VALUES (CURRENT_TIMESTAMP(),FrequenzaPiscine,FrequenzaUtilizzoAreeAllestibili);
 
 
 
 INSERT INTO MV_ResocontoCorsi
 SELECT CURRENT_TIMESTAMP(),D.CodCorso,AVG(D.Frequentatori) 
 FROM( SELECT CodCorso,Giorno,COUNT(*) AS Frequentatori
       FROM  Corso_Giorni 
       GROUP BY CodCorso,Giorno) AS D
GROUP BY D.CodCorso;




 INSERT INTO MV_UtilizzoAttrezzatura(
 SELECT CURRENT_TIMESTAMP(),D.Centro,D.Tipologia,D.CodAttrezzatura,D.NumeroUtilizzi
 FROM ( SELECT S.Centro,A.Tipologia,A.CodAttrezzatura, COUNT(*) AS NumeroUtilizzi
        FROM Attrezzatura A INNER JOIN EsercizioSvolto_Configurazione ESC
        ON ESC.Attrezzatura=A.CodAttrezzatura
         INNER JOIN Sala S
          ON S.CodSala=A.Sala
		 GROUP BY S.Centro,A.CodAttrezzatura,A.Tipologia ) AS D
ORDER BY D.Centro,D.Tipologia,D.NumeroUtilizzi);
    
	

INSERT INTO MV_FasceOrarie
select  CURRENT_TIMESTAMP(),I.Centro,I.Ora1,I.Ora2,COUNT(*) as NumeroAccessiFasciaOraria
from Intervalli I INNER JOIN AccessoCentro AC
       ON
        (I.centro=AC.Centro
         AND
        ((AC.OrarioAccesso>=I.Ora1
         AND
         AC.OrarioAccesso<I.Ora2)
         OR
         (AC.OrarioUscita>I.Ora1
         AND
         AC.OrarioUscita<=I.Ora2)))
group by I.centro,I.Ora1,I.Ora2 
order by I.centro,I.Ora1,I.Ora2;	
	
 
 END $$
 DELIMITER ;
 
  