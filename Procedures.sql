drop procedure if exists RispondiRichiestaAmicizia;
delimiter $$
create procedure RispondiRichiestaAmicizia(in UtenteA char(60), in UtenteB char(60), in esito char(20))
begin
  update richiestaamicizia
  set stato=esito
  where UtenteRichiedente=UtenteA
        and
        Utentedestinatario=UtenteB;
end $$
delimiter ;

/*drop procedure if exists CreaCerchia;
delimiter $$
create procedure CreaCerchia(in _codcerchia Varchar(20),in _nomecerchia Varchar(100),in _utente Varchar(60), in _sport Varchar(50))
BEGIN
  insert into Cerchia (CodCerchia,NomeCerchia,Utente,Sport,NumeroPartecipantiCerchia)
  values(_codcerchia,_nomecerchia,_utente,_sport,1);
END $$
delimiter ;  NO  */ 

DROP PROCEDURE IF EXISTS InserimentoCaratteristiche;
 DELIMITER $$
 CREATE PROCEDURE InserimentoCaratteristiche(IN _Cliente Varchar(16), IN _Altezza double, IN _Peso double, IN _PercentualeGrasso double, IN _PercentualeMagro double, IN _Acqua double)
 BEGIN 
  DECLARE Stato Varchar(15) DEFAULT '';
  DECLARE _Sesso Varchar(1) DEFAULT '';
  SELECT Sesso INTO _Sesso FROM Cliente WHERE CodFiscale=_Cliente;
  IF (_Altezza<=0 OR _Peso<=0 OR _PercentualeGrasso<=0 OR _PercentualeMagro<=0 OR _Acqua<=0) THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT='Valori non validi';
  END IF;
    
    
  IF (_Sesso='M') THEN
  BEGIN
    IF _PercentualeGrasso<=10 THEN 
      SET Stato='Sottopeso';
    ELSEIF (_PercentualeGrasso>10 AND _PercentualeGrasso<=20) THEN
      SET  Stato='Normopeso';
    ELSE
      SET Stato='Sovrappeso';
	END IF;
  END;
  ELSE
  BEGIN
    IF _PercentualeGrasso<=20 THEN 
      SET Stato='Sottopeso';
    ELSEIF (_PercentualeGrasso>20 AND _PercentualeGrasso<=30) THEN
      SET  Stato='Normopeso';
    ELSE
      SET Stato='Sovrappeso';
	END IF; 
  END;
  END IF;
  INSERT INTO CaratteristicheFisiche 
  VALUES (_Cliente,_Altezza,_Peso,_PercentualeGrasso,_PercentualeMagro,_Acqua,Stato);
  END $$
  DELIMITER ;
  
  
  
  
DROP PROCEDURE IF EXISTS ConsigliaCerchia;
DELIMITER $$
CREATE PROCEDURE ConsigliaCerchia ( IN utenteA CHAR(60),IN utenteB CHAR(60))
BEGIN
  declare CerchiaTarget char(50) default ' ';
  declare finito int default 0;
  
  declare CerchieTarget cursor for
  (select Distinct(C.Codcerchia)
   from Cerchia C
        inner join 
        Interesse I
        on 
        (C.Interesse1=I.Interesse
         OR
         C.Interesse2=I.Interesse
         OR
         C.Interesse3=I.Interesse)
         
   where I.username=utenteB
         and
         C.utente=utenteA);
   
   declare continue handler for not found set finito=1;
   
   open CerchieTarget ;
   
   InserisciConsigliati:  LOOP
     fetch CerchieTarget into CerchiaTarget;
     if finito=1 then
       leave inserisciconsigliati;
	 end if;
     insert into Consigliati
     values(utenteB,Cerchiatarget,InteressiInComuneCerchia(utenteB,cerchiatarget));
     end loop;
   
   close CerchieTarget;
     
END $$
delimiter ;



  
  DROP PROCEDURE IF EXISTS ConsigliaCerchia2 ;
delimiter $$
CREATE PROCEDURE ConsigliaCerchia2 (IN _Utente1 VARCHAR(60), IN _Utente2 VARCHAR(60))
BEGIN
  declare CerchiaTarget char(50) default ' ';
  declare finito int default 0;
  
  declare CerchieTarget cursor for
  (select C.Codcerchia
   from Cerchia C
        inner join 
        Interesse I
        on 
        (C.Interesse1=I.interesse
         OR
         C.Interesse2=I.interesse
         OR
         C.Interesse3=I.interesse)
   where I.username=_utente2
         and
         C.utente=_utente1);
   
   declare continue handler for not found set finito=1;
   
   open CerchieTarget ;
   
   RimuoviConsigliati : LOOP
     fetch CerchieTarget into CerchiaTarget;
     if finito=1 then
       leave Rimuoviconsigliati;
	 end if;
     delete from  Consigliati
     where utenteconsigliato=_utente2
           and
           cerchia=cerchiatarget;
     end loop;
     close CerchieTarget;
end $$
delimiter ;
  
  
  
  
  
  
  
DROP PROCEDURE IF EXISTS InserisciSfida;
DELIMITER $$
CREATE PROCEDURE InserisciSfida (IN _TitoloSfida VARCHAR(50), IN _Username VARCHAR(50),
                                 IN _Testo TEXT, IN _IndirizzoWeb VARCHAR(60),IN _DataLancioSfida DATE, IN _DataInizioSfida DATE, 
                                 IN _DataFineSfida DATE, IN _Scopo VARCHAR(50), IN _ValoreScopo INT, 
                                 IN _SchedaAlimentazione VARCHAR (50), IN _SchedaAllenamento VARCHAR(50),
                                 IN _CodiceSfida VARCHAR(50),IN _CodPost VARCHAR(50))
 BEGIN                                
  
   IF (_Username NOT IN (SELECT Username FROM ProfiloSocial )) THEN
      SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT='Username inesistente';
   END IF;
   
   INSERT INTO PostPrincipale (CodPost,TitoloPost,Username,Testo,StringaIndirizzoWeb,AreaForum)
    VALUES (_CodPost,_TitoloSfida,_Username,_Testo,_IndirizzoWeb,'Sfide');
   
   INSERT INTO Sfida (CodSfida,TitoloSfida,UtenteProponente,DataLancioSfida,DataInizioSfida,DataFineSfida,
                      ScopoDaRaggiungere,ValoreScopo,SchedaAllenamento,SchedaAlimentazione,Codpost)
	VALUES (_CodiceSfida,_TitoloSfida,_Username,_DataLancioSfida,_DataInizioSfida,_DataFineSfida,_Scopo,
            _ValoreScopo,_SchedaAllenamento,_SchedaAlimentazione,_Codpost);
   INSERT INTO AderisciSfida 
   VALUES (_Username,_CodiceSfida);
   
   INSERT INTO Esercizio_Modifica
   SELECT E.CodEsercizio,_CodiceSfida,E.NumeroRipetizioni,E.NumeroSerie,E.DuratainMinuti,E.TempodiRecuperoSecondi,ES.Giorno
   FROM Esercizio E INNER JOIN EsercizioScheda ES
    ON E.CodEsercizio=ES.Esercizio
   WHERE ES.Scheda=_SchedaAllenamento;
   
   INSERT INTO Esercizio_Modifica_Config
   SELECT EC.Esercizio,_CodiceSfida,EM.GiornoScheda,EC.Attrezzatura,EC.TipoConfigurazione,EC.ValoreConfigurazione
   FROM Esercizio_Configurazione EC INNER JOIN Esercizio_Modifica EM
    ON EM.Esercizio=EC.Esercizio
   WHERE EM.Sfida=_CodiceSfida;
   
   
            
	
    
END $$

DELIMITER ;


DROP PROCEDURE IF EXISTS CheckSfide;
DELIMITER $$
CREATE PROCEDURE CheckSfide (IN _NomeUtente VARCHAR(50))
BEGIN 
 SELECT A.Utente1, S.TitoloSfida, S.NumeroPartecipanti
 FROM Amicizia A INNER JOIN Sfida S
  ON A.Utente1=S.UtenteProponente
 WHERE A.Utente2=_NomeUtente
 UNION
 SELECT A.Utente2, S.TitoloSfida,S.NumeroPartecipanti
 FROM Amicizia A INNER JOIN Sfida S
  ON A.Utente2=S.UtenteProponente
 WHERE A.Utente1=_NomeUtente;
 
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS CalcoloSforzoGiornaliero;
DELIMITER $$
CREATE PROCEDURE CalcoloSforzoGiornaliero (IN _Username VARCHAR(50), IN _Data DATE, IN _Sfida VARCHAR(50), IN _Sforzo VARCHAR(20))
BEGIN 

 DECLARE Conteggio INT DEFAULT 0;
 DECLARE Effettivo INT DEFAULT 0;
 DECLARE EffettivoConfig INT DEFAULT 0;
 DECLARE OttimaleConfig INT DEFAULT 0;
 DECLARE Ottimale INT DEFAULT 0;
 DECLARE CodEx VARCHAR(10) DEFAULT '';
 DECLARE GiornoSchd INT DEFAULT 0;
 DECLARE Percentuale DOUBLE DEFAULT 0.00;
 DECLARE PercentualeConfig DOUBLE DEFAULT 0.00;
 DECLARE ValSforzo INT DEFAULT 0;
 DECLARE Scheda_Allenamento VARCHAR(25) DEFAULT '';
 DECLARE NumConfig INT DEFAULT 0;
 DECLARE TotConfig INT DEFAULT 0;
 
 DECLARE Finito BOOL DEFAULT 0;
 
 
 
 
 DECLARE EserciziSvolti CURSOR FOR 
  SELECT Esercizio,(IF(Ripetizioni=0 OR Ripetizioni IS NULL ,Durata,Ripetizioni) *
                    IF (NumeroSerie=0 OR NumeroSerie IS NULL,1,NumeroSerie)),GiornoScheda
  FROM EsercizioSvolto  
  WHERE Cliente=(SELECT PS.Proprietario
                 FROM ProfiloSocial PS
                 WHERE PS.Username=_Username)
  AND _Data=DATE(IstanteInizio)
  AND Sfida=_Sfida;
                 
                 
 DECLARE CONTINUE HANDLER FOR NOT FOUND 
  SET Finito=1;
  
  
  OPEN EserciziSvolti;
  
  Cursore: LOOP
   BEGIN 
    FETCH EserciziSvolti INTO CodEx,Effettivo,GiornoSchd;
    
    IF Finito=1 THEN
      LEAVE Cursore;
	END IF;
      
     
     SELECT IF(EM.Ripetizioni=0 OR EM.Ripetizioni IS NULL,EM.Durata,EM.Ripetizioni) * 
             IF (EM.NumeroSerie=0 OR EM.NumeroSerie IS NULL,1,EM.NumeroSerie) INTO Ottimale
     FROM Esercizio_Modifica EM
     WHERE Esercizio=CodEx
      AND EM.GiornoScheda=GiornoSchd
      AND EM.Sfida=_Sfida;
      
     SELECT SUM(ValoreConfigurazione) INTO OttimaleConfig
     FROM Esercizio_Modifica_Config
     WHERE Esercizio=CodEx
      AND Sfida=_Sfida
      AND GiornoScheda=GiornoSchd;
      
      SELECT SUM(ValoreConfigurazione),COUNT(*) INTO EffettivoConfig, NumConfig
      FROM EsercizioSvolto_Configurazione ESC INNER JOIN EsercizioSvolto ES
       ON ESC.Esercizio=ES.Esercizio
       AND ESC.Cliente=ES.Cliente
       AND ES.IstanteInizio=ESC.IstanteInizio
      WHERE ES.Esercizio=CodEx
       AND ES.GiornoScheda=GiornoSchd
       AND ES.Sfida=_Sfida
       AND DATE(ES.IstanteInizio)=_Data
       AND ESC.Cliente=(SELECT PS.Proprietario
                        FROM ProfiloSocial PS
                        WHERE PS.Username=_Username);
   
   SET Conteggio=Conteggio + 1;
   SET Percentuale=Percentuale+((Effettivo/Ottimale)*100);
   SET PercentualeConfig=PercentualeConfig+((EffettivoConfig/OttimaleConfig)*100);
   SET TotConfig=TotConfig + NumConfig;
   END;
   END LOOP;
    CLOSE EserciziSvolti;
    
   IF Conteggio=0 THEN 
     SIGNAL SQLSTATE '45000'
     SET MESSAGE_TEXT='Non hai svolto esercizi della sfida oggi';
   END IF;
    
    IF (TotConfig>0) THEN
     SET ValSforzo=(AssegnaSforzo(Percentuale/Conteggio) + AssegnaSforzo(PercentualeConfig/TotConfig))/2;
    ELSE 
     SET ValSforzo=AssegnaSforzo(Percentuale/Conteggio);
     END IF;
   INSERT INTO Sforzo
   VALUES (_Sforzo,_Sfida,_Username,ValSforzo,_Data);
   
END $$
DELIMITER ;







DROP PROCEDURE IF EXISTS Set_Finito;
DELIMITER $$
CREATE PROCEDURE Set_Finito()
BEGIN

  DECLARE _Sfida VARCHAR(20) DEFAULT '';
  DECLARE Finito INT DEFAULT 0;
  
  DECLARE CercaSfide CURSOR FOR 
   SELECT CodSfida
   FROM Sfida S LEFT JOIN Vincitore_Sfida VS
    ON S.CodSfida=VS.Sfida
   WHERE VS.Sfida IS NULL 
    AND DataFineSfida<=Current_date();
   
  DECLARE CONTINUE HANDLER FOR NOT FOUND 
   SET Finito=1;
   
   OPEN CercaSfide;
   Scansione: LOOP
    BEGIN
    FETCH CercaSfide INTO _Sfida;
    
    IF (Finito=1) THEN
      LEAVE Scansione;
	END IF;
    
    INSERT INTO Log_Sfida
    VALUES (_Sfida);
    
    INSERT INTO Log_Conclusioni
    SELECT A.CodSfida,A.Utente
    FROM AderisciSfida A
    WHERE A.Utente NOT IN (SELECT S.Username
							FROM SfidaConclusa S
                            WHERE S.CodSfida=_Sfida);
    
    
    END;
    END LOOP;
    
    
    END $$
    DELIMITER ;
    
    
    
    
    
    
    
DROP PROCEDURE IF EXISTS CalcoloPunteggio_Event;
DELIMITER $$
CREATE PROCEDURE CalcoloPunteggio_Event()
 BEGIN 
     
      
   DECLARE Finito INT DEFAULT 0;
   DECLARE Utente VARCHAR(60) DEFAULT '';
   DECLARE _Sfida VARCHAR(20) DEFAULT '';
   DECLARE MediaSforzo DOUBLE DEFAULT 0;
   DECLARE VotoTempo INT DEFAULT 0;
   DECLARE VotoObiettivo INT DEFAULT 0;
   DECLARE DataF DATE;
   DECLARE DataI DATE;
   DECLARE VotoFinale DOUBLE DEFAULT 0.00;
   DECLARE MisurazioneFinale DOUBLE DEFAULT 0;
	  
   DECLARE Conclusioni CURSOR FOR 
	SELECT Username,Sfida 
	FROM log_Conclusioni;
    
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND
     SET Finito=1;
     
    OPEN Conclusioni;
   
    Cursore: LOOP
     BEGIN
       FETCH Conclusioni INTO Utente,_Sfida;
       
       IF Finito=1 THEN
         LEAVE Cursore;
	   END IF;
       
       
       
       SELECT AVG(S.ValoreSforzo) INTO MediaSforzo    /* CALCOLO LO SFORZO MEDIO */
       FROM Sforzo S
       WHERE S.Username=Utente
       AND S.CodSfida=_Sfida;
       
       SELECT DataInizioSfida,DataFineSfida INTO DataI,DataF
       FROM Sfida
       WHERE CodSfida=_Sfida;
       
       
       SET VotoTempo=VotoGiorni(DataI,DataF,DataF);       /* Calcolo quanti giorni ha impiegato per concludere la sfida */
       
      SELECT MS.ValoreMisurazione INTO MisurazioneFinale      /* PRENDO L'ULTIMA MISURAZIONE DELLA SFIDA */
   FROM MisurazioneSfida MS
   WHERE MS.Visita=(SELECT V.Codvisita
					   FROM Visita V
                       WHERE V.Cliente=(SELECT PS.Proprietario
									    FROM ProfiloSocial PS 
                                        WHERE PS.Username=Utente)
						AND V.DataVisita=(SELECT MAX(V2.DataVisita)
                                        FROM Visita V2
                                        WHERE Cliente=V.Cliente))
	 AND MS.Sfida=_Sfida;
       
       SET VotoObiettivo=VotoMisurazioni(MisurazioneFinale,(SELECT ValoreScopo FROM Sfida WHERE CodSfida=_Sfida)); /* Calcolo la prestazione del cliente */
       
       SET VotoFinale=(MediaSforzo+VotoObiettivo+VotoTempo)/4;
       
       INSERT INTO SfidaConclusa 
       VALUES (_Sfida,Utente,DataF,VotoFinale);   /* Inserisco il tutto */
       
       END;
	  END LOOP;
       
	  CLOSE Conclusioni;
       
       
END $$
DELIMITER ;
       
       
       
       
       
       
       
       
       
       
DROP PROCEDURE IF EXISTS CalcoloPunteggio;             /* Non la si deve scambiare con la procedure dell'event */
DELIMITER $$
CREATE PROCEDURE CalcoloPunteggio(IN _Sfida VARCHAR(20), IN _Utente VARCHAR(60),IN _DataConclusione DATE)
 BEGIN 
     
   DECLARE MediaSforzo DOUBLE DEFAULT 0;
   DECLARE VotoTempo INT DEFAULT 0;
   DECLARE VotoObiettivo INT DEFAULT 0;
   DECLARE DataF DATE;
   DECLARE DataI DATE;
   DECLARE VotoFinale DOUBLE DEFAULT 0.00;
   DECLARE MisurazioneFinale INT DEFAULT 0;
   
      
   SELECT AVG(S.ValoreSforzo) INTO MediaSforzo    /* CALCOLO LO SFORZO MEDIO */
   FROM Sforzo S
   WHERE S.Username=_Utente
   AND S.CodSfida=_Sfida
   GROUP BY S.Username;
       
     
     
   SELECT DataInizioSfida,DataFineSfida INTO DataI,DataF
   FROM Sfida
   WHERE CodSfida=_Sfida;
       
       
   SET VotoTempo=VotoGiorni(DataI,DataF,_DataConclusione);       /* Calcolo quanti giorni ha impiegato per concludere la sfida */
       
       
       
   SELECT MS.ValoreMisurazione INTO MisurazioneFinale      /* PRENDO L'ULTIMA MISURAZIONE DELLA SFIDA */
   FROM MisurazioneSfida MS
   WHERE MS.Visita=(SELECT V.Codvisita
					   FROM Visita V
                       WHERE V.Cliente=(SELECT PS.Proprietario
									    FROM ProfiloSocial PS 
                                        WHERE PS.Username=_Utente)
						AND V.DataVisita=(SELECT MAX(V2.DataVisita)
                                        FROM Visita V2
                                        WHERE Cliente=V.Cliente))
  AND MS.Sfida=_Sfida;
       
   SET VotoObiettivo=VotoMisurazioni(MisurazioneFinale,(SELECT ValoreScopo FROM Sfida WHERE CodSfida=_Sfida)); /* Calcolo la prestazione del cliente */
       
       
   SET VotoFinale=(MediaSforzo+VotoObiettivo+VotoTempo)/4;
       
    
    
   INSERT INTO SfidaConclusa 
   VALUES (_Sfida,_Utente,_DataConclusione,VotoFinale);   /* Inserisco il tutto */
       
      
       
END $$
DELIMITER ;
	  
     
      
    
    
DROP PROCEDURE IF EXISTS Rank_Sfida;
DELIMITER $$
CREATE PROCEDURE Rank_Sfida()
BEGIN

INSERT INTO Vincitore_Sfida
SELECT SC.CodSfida,SC.Username
FROM SfidaConclusa SC
WHERE SC.VotoSfida=(SELECT MAX(SC2.VotoSfida)
                    FROM SfidaConclusa SC2
                    WHERE SC2.CodSfida=SC.CodSfida);
                    
END $$
DELIMITER ; 
   

    
    
    
    
DROP PROCEDURE IF EXISTS CreaOrdine;
DELIMITER $$
CREATE PROCEDURE CreaOrdine (IN _CodOrdine CHAR(30), IN _Fornitore CHAR(25), IN _Centro CHAR(20) ,
                             IN _MetodoPagamento CHAR (25))
BEGIN

  IF EXISTS ( select *
              from Ordine
			  where Fornitore=_Fornitore
                    AND
					Stato='incompleto'
                    AND
                    Centro=_Centro) THEN
              SIGNAL SQLSTATE '45000'
              SET MESSAGE_TEXT="Il centro ha già aperto una procedura di acquisto per questo venditore";
  END IF; 
                                
  INSERT INTO Ordine
  VALUES(_CodOrdine,_Fornitore,_Centro,'incompleto',_MetodoPagamento);
  
  END $$
  DELIMITER ;
  
/* OK */

DROP PROCEDURE IF EXISTS AggiungiProdottoInventario;
DELIMITER $$
CREATE PROCEDURE AggiungiProdottoInventario(IN _CodIntegratore char(60), IN _Magazzino char(25),
											IN _Costo INT)
BEGIN

  IF _Codintegratore NOT IN (select NomeCommerciale
						     from Integratore ) THEN
	 SIGNAL SQLSTATE '45000'
     SET MESSAGE_TEXT=" L'integratore non esiste ";
  END IF;
  
  INSERT INTO InventarioMagazzino
  VALUES (_Magazzino,_CodIntegratore,_Costo);

END $$
DELIMITER ;
  
 DROP PROCEDURE IF EXISTS InviaOrdine;
DELIMITER $$
CREATE PROCEDURE InviaOrdine (IN _CodOrdine CHAR(30),IN _DataConsegnaPreferita DATE)
BEGIN
  declare _centro char(20) default '';
  declare _nomeintegratore char(60) default ' ';
  declare _quantita int default 0;
  declare _finito int default 0;
  declare _capienzavirtuale INT default 0;
  declare _capienzamassima INT default 0;
  declare _quantitaTot INT default 0;
  declare _stato CHAR(30) default ' ';
  
  declare ProdottiOrdine cursor for
  (SELECT NomeIntegratore,Quantita
   FROM Acquisto
   WHERE CodOrdine=_CodOrdine);
   
   declare continue handler for not found
   set _finito=1;

SELECT O.centro,O.stato,M.capienzamassima,M.capienzaattualevirtuale into _centro,_stato,_capienzamassima,_capienzavirtuale
  FROM Ordine O natural join Magazzino M
  WHERE O.CodOrdine=_CodOrdine;
  
  IF _stato=' ' THEN

           SIGNAL SQLSTATE '45000'
           SET MESSAGE_TEXT = "Ordine inesistente";
  ELSE
                      IF  _stato='evaso' THEN
			   SIGNAL SQLSTATE '45000'
               SET MESSAGE_TEXT="Ordine già inviato";
  END IF;
  END IF;

 
  
  OPEN ProdottiOrdine;
  
  Conta : LOOP
    BEGIN
      FETCH ProdottiOrdine INTO _nomeintegratore,_quantita;
      
      IF _finito=1 THEN
        LEAVE Conta;
	  END IF;

     set _quantitaTot=_quantitaTot+_quantita;
      
	END;
	END LOOP;

  CLOSE ProdottiOrdine;

IF _capienzavirtuale+_quantitaTot>_capienzamassima THEN

   SIGNAL SQLSTATE '45000'
   SET MESSAGE_TEXT="La merce richiesta non entra in magazzino ";
END IF;

     UPDATE Magazzino 
     SET CapienzaAttualeVirtuale=CapienzaAttualeVirtuale+_quantitaTot
     Where Centro=_centro;
      

  
  UPDATE Ordine
  SET Stato='evaso'
  WHERE CodOrdine=_CodOrdine;
  
  INSERT INTO OrdiniEvasi
  VALUES(_CodOrdine,current_date,_DataConsegnaPreferita,'in attesa');
  
END $$
DELIMITER ;

 DROP PROCEDURE IF EXISTS AggiungiAlCarrello;
DELIMITER $$
CREATE PROCEDURE AggiungiAlCarrello (IN _CodOrdine CHAR(30),IN _CodProdotto CHAR(30), IN _NomeIntegratore CHAR(30) , 
                                     IN _Quantità INT)

BEGIN
  declare _Capienza INT DEFAULT 0;
  declare _CapienzaMax INT DEFAULT 0;
  declare _fornitore CHAR(80) DEFAULT ' ';
  declare _magazzino CHAR(25) default ' ';
  
  set _magazzino=(SELECT codmagazzino
                              FROM ordine natural join magazzino
                              WHERE codordine=_codordine);
  
  IF _nomeintegratore NOT IN (SELECT integratore
                                                    FROM inventariomagazzino	
                                                    WHERE magazzino=_magazzino) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT="Prima aggiungere il prodotto nell'inventario !";
        
      END IF;
      
	  

  IF NOT EXISTS (SELECT * 
                               FROM Ordine
                               WHERE CodOrdine=_CodOrdine) THEN
                 SIGNAL SQLSTATE '45000'
                 SET MESSAGE_TEXT = "Ordine inesistente";
  ELSE
    IF EXISTS (SELECT *
                        FROM Ordine
                        WHERE CodOrdine=_CodOrdine
                        AND
                        Stato='evaso') THEN
           SIGNAL SQLSTATE '45000'
           SET MESSAGE_TEXT="Ordine già inviato";
  END IF;
  END IF;
  
  SET _fornitore = (SELECT fornitore
		   FROM Ordine
                               WHERE CodOrdine=_CodOrdine);
  
  IF _NomeIntegratore NOT IN (SELECT NomeCommerciale
                                                    FROM Integratore
                                                    WHERE Fornitore=_fornitore) THEN 
            SIGNAL SQLSTATE '45000'
             SET MESSAGE_TEXT='Il fornitore non vende il prodotto richiesto';
  END IF;
  
  INSERT INTO Acquisto
  VALUES (_CodOrdine,_Codprodotto,_NomeIntegratore,_Quantita);

END $$
DELIMITER ;




							
  

/* OK */



DROP PROCEDURE IF EXISTS StipaMerce;
DELIMITER $$
CREATE PROCEDURE StipaMerce (IN _CodOrdine CHAR(30), IN _DataScadenza DATE )
BEGIN
  
  
  declare _finito int default 0;
  declare _nomeintegratore char(60) default ' ';
  declare _quantita int default 0;
  declare _magazzino char(25) default ' ';
  declare _stato char(20) default ' ';
  declare _codprodotto char(30) default ' ';
  declare _centro char(20) default ' ';
  
  
  declare ProdottiOrdine cursor for
  (select CodProdotto,NomeIntegratore,Quantita
   from Acquisto
   where CodOrdine=_CodOrdine);
   
   declare continue handler for not found set _finito=1;
   
   set _centro = (select centro
                  from ordine
                  where codordine=_codordine);
   
   set _magazzino=( select M.CodMagazzino
                    from Magazzino M NATURAL JOIN Ordine O
                    where O.CodOrdine=_CodOrdine);
	
   set _stato=(select stato
               from ordinievasi
               where CodOrdine=_CodOrdine);
	
    IF _stato <> 'merce arrivata' THEN
      SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT="La merce non è ancora arrivata";
	END IF;
   
   open ProdottiOrdine;
   
   AggiornaDeposito : LOOP
    BEGIN
      FETCH ProdottiOrdine INTO _codprodotto,_nomeintegratore,_quantita;
      
      IF _finito=1 THEN
        LEAVE AggiornaDeposito;
	  END IF;
      
      INSERT INTO MerceMagazzino
      VALUES(_codprodotto,_nomeintegratore,_magazzino,_quantita,_DataScadenza,NULL);
      
      
	END;
	END LOOP;
    
    close ProdottiOrdine;
    
    delete from Ordine where CodOrdine=_CodOrdine;
END $$
DELIMITER ;

   
DROP PROCEDURE IF EXISTS VenditaIntegratori;
DELIMITER $$
CREATE PROCEDURE VenditaIntegratori (IN _codvendita CHAR(25),IN _cliente CHAR(16), IN _centro CHAR(20),
                                     IN _integratore CHAR(30),IN _datavendita DATE,IN _quantita INT,
                                     IN _codprodotto CHAR(30))
                                     
BEGIN
     declare quantitadepositoprodotto int default 0;
     declare _costo int default 0;
     declare _magazzino CHAR(25) default ' ';
     declare _rank char(10) default ' ';
     
     set _magazzino=(select codmagazzino
		     from magazzino
                     where centro=_centro);
     
           set _costo=(select costo
                  from inventariomagazzino
                  where magazzino=_magazzino
                        and
                        integratore=_integratore);
      

      
      
      select quantita,rank into quantitadepositoprodotto,_rank
      from MerceMagazzino
      where codprodotto=_codprodotto;
                                     
      IF quantitadepositoprodotto<_quantita THEN
             SIGNAL SQLSTATE '45000'
             SET MESSAGE_TEXT="Al momento quello stock non dispone della quantità richiesta";
	  END IF;
      
      INSERT INTO vendite 
      VALUES (_codvendita,_cliente,_centro,_integratore,_datavendita,_quantita);
      
      UPDATE Magazzino 
      SET CapienzaAttualeVirtuale=CapienzaAttualeVirtuale-_quantita  
      WHERE Centro=_centro;
            
	  IF quantitadepositoprodotto-_quantita=0 THEN
      
	  DELETE FROM mercemagazzino
	  WHERE codprodotto=_codprodotto;
	
      ELSE
      
	  UPDATE MerceMagazzino
      SET quantita=quantita-_quantita
      WHERE CodProdotto=_codprodotto;
      
      END IF;
      
      INSERT INTO Log_VenditeIntegratori
      VALUES(_codvendita,_integratore,_quantita,_quantita*_Costo*ScontoRank(_rank),_centro);
	
		
END $$
DELIMITER ;



DROP PROCEDURE IF EXISTS DecrementaMagazzino;
DELIMITER $$
CREATE PROCEDURE DecrementaMagazzino( IN _centro char(20), IN _codordine char(30))
BEGIN
  declare _finito INT default 0;
  declare _nomeintegratore char(60) default ' ';
  declare _quantita INT default 0;
  declare _quantitatot INT default 0;
  
  declare ProdottiDaEliminare cursor for
  (select nomeintegratore,quantita
   from acquisto
   where codordine=_codordine);
   
   declare continue handler for not found set _finito=1;
   
   open ProdottiDaEliminare;
   
   Decrementa: LOOP
     BEGIN
       FETCH ProdottiDaEliminare INTO _nomeintegratore,_quantita;
       IF _finito=1 THEN
         LEAVE Decrementa;
	   END IF;
       
       SET _quantitatot=_quantitatot+_quantita;
	END;
    END LOOP;
   close ProdottiDaEliminare;
   
      
     UPDATE Magazzino
      SET  CapienzaAttualeVirtuale=CapienzaAttualeVirtuale-_quantitatot
      WHERE Centro=_centro;
      
END $$
DELIMITER ;








DROP PROCEDURE IF EXISTS EliminaOrdiniFalliti;
DELIMITER $$
CREATE PROCEDURE EliminaOrdiniFalliti (IN _centro char(20))
BEGIN
  declare finito INT default 0;
  declare _codordine char(30) default ' ';
  
  declare OrdiniFalliti cursor for
  (select O.CodOrdine
   from Ordinievasi OE inner join Ordine O on OE.CodOrdine=O.CodOrdine
   where OE.stato='fallito'
		 AND
         O.centro=_centro);
  
  
  declare continue handler for not found set finito=1;
  
  IF NOT EXISTS (select * 
                 from OrdiniEvasi OE inner join Ordine O on OE.CodOrdine=O.CodOrdine
                 where OE.stato='fallito'
					    AND
					   O.centro=_centro) THEN
     SIGNAL SQLSTATE '45000'
     SET MESSAGE_TEXT ="Nessun ordine fallito";
 END IF;  
 
 open OrdiniFalliti;
 
 Elimina: LOOP
   BEGIN
     FETCH OrdiniFalliti INTO _codordine;
     IF finito=1 THEN
       LEAVE Elimina;
	 END IF;
     CALL DecrementaMagazzino(_centro,_codordine);
     delete from ordine where codordine=_codordine;
   END;
   END LOOP;
   
close OrdiniFalliti;

END $$

DELIMITER ;




DROP PROCEDURE IF EXISTS Aggiungi_Contratto;
DELIMITER $$
CREATE PROCEDURE Aggiungi_Contratto(IN _CodContratto VARCHAR(10), IN _Consulente VARCHAR(50), IN _DuratainMesi INT, 
                                    IN _ModPagamento VARCHAR(12),  IN _Tipologia VARCHAR(15), IN _SedeSottoscrizione VARCHAR(10), 
                                    IN _Scopo VARCHAR(40), IN _DataSottoscrizione DATE, IN _Cliente VARCHAR(50))
                                    
BEGIN 
  
  
  IF (_Tipologia NOT IN (SELECT NomeAbbonamento FROM AbbonamentoStandard) AND _Tipologia<>'Personalizzato') THEN
     
   
      BEGIN
       SET @Errore=CONCAT('Nome abbonamento ',_Tipologia,' non esistente!');
       
       SIGNAL SQLSTATE '45000'
       SET MESSAGE_TEXT=@Errore;
	  
      END;
   ELSE 
    BEGIN
   IF (_Scopo<>'Dimagrimento'  AND _Scopo<>'Potenziamento Muscolare' AND _Scopo<>'Attività ricreativa' ) THEN
     SIGNAL SQLSTATE '45000'
     SET MESSAGE_TEXT='Scopo non valido';
   END IF;
   
   
  IF (_DataSottoscrizione='' OR _DataSottoscrizione IS NULL) THEN
  
    SET _DataSottoscrizione=CURRENT_DATE();
  
  END IF;
     INSERT INTO Contratto
     VALUES (_CodContratto,_Consulente,_DuratainMesi,_ModPagamento,_Tipologia,_SedeSottoscrizione,_Scopo,_DataSottoscrizione,_Cliente,
             0);
 END ;
 END IF;
END $$
DELIMITER ;



DROP PROCEDURE IF EXISTS RegistraAccesso_Centro;
DELIMITER $$
CREATE PROCEDURE RegistraAccesso_Centro (IN _Cliente VARCHAR(50) ,IN _Centro VARCHAR(50), IN _DataAccesso DATE , IN _OrarioAccesso TIME)
BEGIN
   
   DECLARE Armadietto_Accesso VARCHAR(20) DEFAULT '';
   DECLARE Contatore INT DEFAULT 0;
   DECLARE Password_Armadietto VARCHAR(8) DEFAULT '';
   DECLARE ElementoPass INT DEFAULT 0;
   DECLARE _Sesso VARCHAR(1) DEFAULT '';
   
   SELECT Sesso INTO _Sesso
   FROM Cliente
   WHERE CodFiscale=_Cliente;
   
   SELECT A.CodArmadietto INTO Armadietto_Accesso
   FROM Armadietto A INNER JOIN Spogliatoio S
    ON A.IDSpogliatoio=S.CodSpogliatoio
   WHERE A.CodArmadietto NOT IN (SELECT LA.ArmadiettoAssegnato
                                 FROM Log_Accesso LA
                                 WHERE LA.Centro=_Centro)
    AND S.Centro=_Centro
    AND S.SessoAccedenti=_Sesso
   LIMIT 1;
   
   
   
   IF (Armadietto_Accesso<>'' AND Armadietto_Accesso IS NOT NULL) THEN
   
     BEGIN 
     WHILE Contatore<8 DO
   
       BEGIN
   
	     SELECT FLOOR(Rand()*10) INTO ElementoPass;
   
         SET Password_Armadietto=CONCAT(Password_Armadietto,ElementoPass);
   
         SET Contatore=Contatore+1;

       END ;
       
	  END WHILE;
      
     
       END ;
  END IF;
   
   INSERT INTO Log_Accesso (Cliente,Centro,DataAccesso,OrarioAccesso,ArmadiettoAssegnato,PasswordArmadietto)
   VALUES (_Cliente,_Centro,_DataAccesso,_OrarioAccesso,Armadietto_Accesso,Password_Armadietto);
   

  
END $$
DELIMITER ;
   
   

DROP PROCEDURE IF EXISTS RegistraUscita_Centro;
DELIMITER $$
CREATE PROCEDURE RegistraUscita_Centro(IN _Cliente VARCHAR(50), IN _OrarioUscita TIME )
BEGIN
 
   DECLARE _OrarioAccesso TIME;
   DECLARE _DataAccesso DATE;
   DECLARE _ArmadiettoAssegnato VARCHAR(50) DEFAULT '';
   DECLARE _PasswordArmadietto VARCHAR(8) DEFAULT '';
   DECLARE _Centro VARCHAR(20) DEFAULT '';
   
   
   
   SELECT OrarioAccesso,DataAccesso,ArmadiettoAssegnato,PasswordArmadietto,Centro INTO _OrarioAccesso,_DataAccesso,
                                                                                       _ArmadiettoAssegnato,
                                                                                       _PasswordArmadietto,_Centro
   FROM Log_Accesso
   WHERE Cliente=_Cliente;
   
   
   INSERT INTO AccessoCentro 
   VALUES (_Cliente,_Centro,_DataAccesso,_OrarioAccesso,_ArmadiettoAssegnato,_PasswordArmadietto,_OrarioUscita);
        
        
   DELETE 
   FROM Log_Accesso
   WHERE Cliente=_Cliente;
   
   
END $$
DELIMITER ;



DROP PROCEDURE IF EXISTS RegistraAccesso_Sala;
DELIMITER $$
CREATE PROCEDURE RegistraAccesso_Sala (IN _Cliente VARCHAR(50), IN _Sala VARCHAR(20), IN _DataAccesso DATE, IN _OrarioAccesso TIME)
BEGIN 

   INSERT INTO Log_Sala (Cliente,Sala,DataAccesso,OrarioAccesso)
   VALUES (_Cliente,_Sala,_DataAccesso,_OrarioAccesso);
   
END $$
DELIMITER ;




DROP PROCEDURE IF EXISTS RegistraUscita_Sala;
DELIMITER $$
CREATE PROCEDURE RegistraUscita_Sala (IN _Cliente VARCHAR(50),IN _OrarioUscita TIME)
BEGIN 

   DECLARE _OrarioAccesso TIME;
   DECLARE _DataAccesso DATE;
   DECLARE _Sala VARCHAR(20) DEFAULT '';
   DECLARE _Esiste INT DEFAULT 0;
   DECLARE _EsisteAccesso INT DEFAULT 0;
   
   
   SELECT OrarioAccesso,DataAccesso,Sala INTO _OrarioAccesso,_DataAccesso,_Sala
   FROM Log_Sala
   WHERE Cliente=_Cliente;
   

   
   IF (_Sala IS NULL OR _Sala='') THEN 
     SIGNAL SQLSTATE'45000'
     SET MESSAGE_TEXT='Il cliente non può uscire se non è mai stato nella sala!';
   END IF;
   
   
   SELECT COUNT(*) INTO _Esiste
   FROM AccessoSala
   WHERE DataAccesso=_DataAccesso
    AND OrarioAccesso=(SELECT MAX(AC.OrarioAccesso)
                       FROM AccessoSala AC
                       WHERE AC.Cliente=_Cliente
                         AND AC.DataAccesso=_DataAccesso)
    AND _OrarioUscita BETWEEN OrarioAccesso AND OrarioUscita
    AND Cliente=_Cliente;
    
    IF (_Esiste>0) THEN 
      SIGNAL SQLSTATE'45000'
      SET MESSAGE_TEXT='Si sta inserendo un uscita non lecita!';
	END IF;
   
   INSERT INTO AccessoSala
   VALUES (_Cliente,_Sala,_DataAccesso,_OrarioAccesso,_OrarioUscita);

   DELETE 
   FROM Log_Sala
   WHERE Cliente=_Cliente;
   
END $$
DELIMITER ;
  
   
     
     
   
         
 DROP PROCEDURE IF EXISTS IscrizioneCentroAreeAllestibili;
DELIMITER $$
CREATE PROCEDURE IscrizioneCentroAreeAllestibili(IN _Cliente CHAR(16),IN _Centro CHAR(20))
BEGIN 
  IF EXISTS (select * 
             from SaldoAreeAllestibiliCliente
             where Cliente=_Cliente
                   AND
                   Centro=_Centro) THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT="Hai già sincronizzato l' account con questo centro";
  END IF;
  INSERT INTO SaldoAreeAllestibiliCliente
  VALUES(_Cliente,0,0,_Centro);
END $$
DELIMITER ;   
        
	
    
  
 DROP PROCEDURE IF EXISTS PrenotazioneAreaAllestibile;
DELIMITER $$
CREATE PROCEDURE PrenotazioneAreaAllestibile (IN _CodPrenotazione CHAR(30) , IN _Area CHAR(20),
IN _TipoArea CHAR(30), IN _AttrezzaturaRichiesta BOOL, IN _Cliente CHAR(50), IN _DataAttivita DATE,
IN _InizioAttivita TIME , IN _FineAttivita TIME )
BEGIN
  declare _tipologiacontratto CHAR(30) default ' ';
  declare _sede               CHAR(20) default ' ';
  
  set _sede = (select sede
               from areaallestibile
               where codarea=_area);
  
  IF NOT EXISTS  (select *
                  from tariffeareeallestibili
                  where codarea=_area
                             AND
                            tipoarea=_tipoarea) THEN
	 SIGNAL SQLSTATE '45000'
     SET MESSAGE_TEXT="Attività non compatibile con l'area richiesta";
  END IF;
  
/* compatibilità area */
  
  IF (ControlloDisponibilitàArea(_Area,_DataAttivita,_InizioAttivita,_FineAttivita) = "occupata") THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT="L'area è già occupata in quella fascia oraria";
  END IF;

/* disponibilità area */

  set _tipologiacontratto=TipologiaContrattoCliente (_Cliente,_sede);
  
  CASE
   
    WHEN _tipologiacontratto='Silver' THEN
    INSERT INTO prenotazione
    values (_Codprenotazione,_Area,_TipoArea,_AttrezzaturaRichiesta,_Cliente,current_timestamp,
          _DataAttivita,_InizioAttivita,_FineAttivita,"gruppo in composizione",10,1);
          
	WHEN _tipologiacontratto='Gold' THEN
    INSERT INTO prenotazione
    values (_Codprenotazione,_Area,_TipoArea,_AttrezzaturaRichiesta,_Cliente,current_timestamp,
          _DataAttivita,_InizioAttivita,_FineAttivita,"gruppo in composizione",15,1);
	
    WHEN _tipologiacontratto='Platinum' THEN
    INSERT INTO prenotazione
    values (_Codprenotazione,_Area,_TipoArea,_AttrezzaturaRichiesta,_Cliente,current_timestamp,
          _DataAttivita,_InizioAttivita,_FineAttivita,"gruppo in composizione",25,1);
	
     WHEN _tipologiacontratto='Personalizzato' THEN
    INSERT INTO prenotazione
    values (_Codprenotazione,_Area,_TipoArea,_AttrezzaturaRichiesta,_Cliente,current_timestamp,
          _DataAttivita,_InizioAttivita,_FineAttivita,"gruppo in composizione",20,1);
	 
     WHEN _tipologiacontratto='senza contratto' THEN
     INSERT INTO prenotazione
    values (_Codprenotazione,_Area,_TipoArea,_AttrezzaturaRichiesta,_Cliente,current_timestamp,
          _DataAttivita,_InizioAttivita,_FineAttivita,"gruppo in composizione",5,1);

  END CASE;

END $$
DELIMITER ;





DROP PROCEDURE IF EXISTS AggiungiPartecipante;   
DELIMITER $$
CREATE PROCEDURE AggiungiPartecipante(IN _Cliente CHAR(30),IN  _CodPrenotazione CHAR(30))
BEGIN 
  declare _tipologiacontratto CHAR(30) default ' ';
  declare _clienterichiedente CHAR(30) default ' ';
  declare _sede CHAR(20) default ' ';
  declare _stato CHAR(30) default ' ';
  declare _maxpartecipanti INT default 0;
  declare _numtotpartecipanti INT default 0;
  
  SELECT A.maxnumeropersone,A.Sede,P.NumPartecipanti,P.Stato,P.ClienteRichiedente
  INTO _maxpartecipanti,_sede,_numtotpartecipanti,_stato,_clienterichiedente
  FROM prenotazione P inner join areaallestibile A on P.area=A.codarea
  WHERE P.codprenotazione=_codprenotazione;

  
  IF _stato = "da confermare" THEN

      SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT =" La prenotazione è già stata inoltrata";
  END IF;
  
  
  IF _clienterichiedente=_cliente THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT="Chi prenota è già un partecipante";
 END IF;
 
 IF _numtotpartecipanti+1>_maxpartecipanti THEN
   SIGNAL SQLSTATE '45000'
   SET MESSAGE_TEXT="L'area non può ospitare più partecipanti";
 END IF;
 
 INSERT INTO Partecipante
 VALUES (_Cliente,_CodPrenotazione);
 
 UPDATE Prenotazione
 SET NumPartecipanti=NumPartecipanti+1
 WHERE codprenotazione=_codprenotazione;
 
 SET _tipologiacontratto=TipologiaContrattoCliente(_Cliente,_sede);
 
 CASE
   
    WHEN _tipologiacontratto='silver' THEN
    
    UPDATE prenotazione
    SET PunteggioGruppo=PunteggioGruppo+10
    WHERE CodPrenotazione=_codprenotazione;
          
	WHEN _tipologiacontratto='gold' THEN
    
    UPDATE prenotazione
    SET PunteggioGruppo=PunteggioGruppo+15
    WHERE CodPrenotazione=_codprenotazione;
    
	
    WHEN _tipologiacontratto='platinum' THEN
    
	UPDATE prenotazione
    SET PunteggioGruppo=PunteggioGruppo+25
    WHERE CodPrenotazione=_codprenotazione;
    
     WHEN _tipologiacontratto='personalizzato' THEN
     
	UPDATE prenotazione
    SET PunteggioGruppo=PunteggioGruppo+20
    WHERE CodPrenotazione=_codprenotazione;
    
    

	WHEN _tipologiacontratto='senza contratto' THEN
     
	UPDATE prenotazione
              SET PunteggioGruppo=PunteggioGruppo+5
              WHERE CodPrenotazione=_codprenotazione;
    
    END CASE;
    
END $$
DELIMITER ;

DROP PROCEDURE IF EXISTS ConcludiPrenotazione;
DELIMITER $$
CREATE PROCEDURE ConcludiPrenotazione (IN _Codprenotazione CHAR(30))
BEGIN
  declare _numpartecipanti int default 0;
  declare _minpartecipanti int default 0;
  
   SELECT P.numpartecipanti,A.MinNumeroPersone INTO  _numpartecipanti,_minpartecipanti
   FROM Prenotazione P inner join AreaAllestibile A on P.area = A.codarea
   WHERE P.codprenotazione=_codprenotazione;

  IF _numpartecipanti >= _minpartecipanti THEN
						  
  UPDATE Prenotazione
  SET Stato="Da confermare"
  WHERE codprenotazione=_codprenotazione;
  
ELSE
  
  SIGNAL SQLSTATE '45000'
  SET MESSAGE_TEXT="Numero persone insufficienti per usufruire dell'area";
  
  END IF;
  
END $$
DELIMITER ;


DROP PROCEDURE IF EXISTS AccettaRifiutaPrenotazione;
DELIMITER $$
CREATE PROCEDURE AccettaRifiutaPrenotazione(IN _Codprenotazione CHAR(30))
BEGIN
  declare _Area CHAR(20) default ' ';
  declare _DataAttivita DATE;
  declare _InizioAttivita TIME;
  declare _FineAttivita TIME ;
  declare _StatoArea CHAR(20) default ' ';
  declare _PunteggioGruppo INT default 0;
  declare _DataInvioPrenotazione timestamp;
  
  select Area,DataInvioPrenotazione,DataAttivita,InizioAttivita,FineAttivita,PunteggioGruppo into 
         _Area,_DataInvioPrenotazione,_DataAttivita,_InizioAttivita,_FineAttivita,_PunteggioGruppo
  from Prenotazione
  where codprenotazione=_codprenotazione;
  
  set _StatoArea=ControlloDisponibilitàArea(_Area,_DataAttivita,_InizioAttivita,_FineAttivita);
  
  IF _StatoArea="libera" THEN
    IF _punteggiogruppo=(select MAX(PunteggioGruppo)
                         from prenotazione 
                         where area=_area) THEN
		IF NOT EXISTS (select *
                       from prenotazione
                       where Area=_area
                             AND
                             punteggiogruppo=_punteggiogruppo
                             AND
                             DataInvioPrenotazione<_DataInvioPrenotazione
                             AND
                             ((InizioAttivita<=_InizioAttivita
                             AND
                             FineAttivita>=_FineAttivita)
                                OR
		  (InizioAttivita>_InizioAttivita
                               AND
                               FineAttivita<=_FineAttivita)
                                OR
		(InizioAttivita>=_InizioAttivita
                               AND
		FineAttivita<_FineAttivita)
		 OR
		(InizioAttivita>=_InizioAttivita
		   AND
                               FineAttivita<=_FineAttivita))) THEN
		 UPDATE prenotazione
         SET stato="approvata"
         WHERE codprenotazione=_codprenotazione;
	  END IF;
      ELSE UPDATE prenotazione
           SET stato="alternativa"
           WHERE codprenotazione=_codprenotazione;
	  END IF;
      ELSE UPDATE prenotazione
           SET stato="alternativa"
           WHERE codprenotazione=_codprenotazione;
 END IF ;
 END $$
 DELIMITER ;

                         
  

DROP PROCEDURE IF EXISTS EsaminaRichiesteCentro;
DELIMITER $$
CREATE PROCEDURE EsaminaRichiesteCentro(IN _Centro CHAR(20) )
BEGIN 
   declare _finito int default 0;
   declare _codprenotazione CHAR(30) default ' ';
   
   declare PrenotazioniTarget cursor for
   (select codprenotazione
    from prenotazione
    where stato="Da confermare");
    
    declare continue handler for not found set _finito=1;
   
   IF NOT EXISTS (select * 
				  from Prenotazione P inner join AreaAllestibile A on P.Area=A.CodARea
                  where A.Sede=_Centro
                        and
                        P.Stato="Da confermare") THEN
	  SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT="Nessuna richiesta di prenotazione da esaminare";
  END IF;
  
   
   open PrenotazioniTarget;
   
   Esamina: LOOP
     BEGIN
       Fetch PrenotazioniTarget into _codprenotazione;
       IF _finito=1 THEN
         LEAVE Esamina;
	   END IF;
	   CALL AccettaRifiutaPrenotazione(_codprenotazione);
	 END ;
     END LOOP;
	
   close PrenotazioniTarget;
END $$
DELIMITER ;

/* Saldo */




DROP PROCEDURE IF EXISTS CaricaSaldoDaPagare;    
DELIMITER $$
CREATE PROCEDURE CaricaSaldoDaPagare (IN _codprenotazione CHAR(30) )
BEGIN 
  declare _finito int default 0;
  declare _cliente CHAR(16) default ' ';
  declare _contratto CHAR(30) default ' ';
  declare _tariffaoraria int default 0;
  declare _tariffaattrezzatura int default 0;
  declare _dataattivita date ;
  declare _inizioattivita time;
  declare _fineattivita time;
  declare _mese char(15) default ' ';
  declare _anno int;
  declare _centro CHAR(20) default ' ';
  declare _saldo DOUBLE ;
  
  declare Partecipanti cursor for
  (SELECT cliente
   FROM partecipante
   WHERE codprenotazione=_codprenotazione);
   
   declare continue handler for not found set _finito=1;
   
   SELECT P.clienterichiedente,P.dataattivita,P.inizioattivita,P.fineattivita,
		  T.TariffaOrariaPerPersona,T.TariffaAttrezzattura,A.Sede
   INTO   _cliente, _dataattivita,_inizioattivita,_fineattivita,
		  _tariffaoraria,_tariffaattrezzatura,_centro
   FROM prenotazione P NATURAL JOIN TariffeAreeAllestibili T INNER JOIN AreaAllestibile A
		 on P.Area=A.CodArea
   WHERE codprenotazione=_codprenotazione;
                     
   set _mese=MONTHNAME(_dataattivita);
    
    set _anno=YEAR(_dataattivita);
	
    set _contratto = TipologiaContrattoCliente(_cliente,_centro);
		
     set _saldo =(time_to_sec(TIMEDIFF(_fineattivita,_inizioattivita)) / 3600 )  * (_tariffaoraria +
                  _tariffaattrezzatura) * ScontoContratto(_contratto);
	
    INSERT INTO saldiareeallestibilidapagare
    VALUES ( _cliente,_saldo,_mese,_anno,"da pagare",_centro);

     UPDATE SaldoAreeAllestibiliCliente
     SET SaldoMese=SaldoMese+ _saldo, SaldoTotale=SaldoTotale+_saldo
     WHERE Cliente=_cliente;
     

	
    
	open Partecipanti;
	
   CaricoDebito: LOOP
   BEGIN
     FETCH Partecipanti into _cliente;
     IF _finito=1 THEN 
      LEAVE CaricoDebito;
     END IF;
     set _contratto=TipologiaContrattoCliente(_cliente,_centro);
	 set _saldo =(time_to_sec(TIMEDIFF(_fineattivita,_inizioattivita)) / 3600 )  * (_tariffaoraria +
                  _tariffaattrezzatura) * ScontoContratto(_contratto);
	 INSERT INTO saldiareeallestibilidapagare
     VALUES ( _cliente,_saldo,_mese,_anno,"da pagare",_centro); 
     UPDATE SaldoAreeAllestibiliCliente
     SET SaldoMese=SaldoMese+ _saldo, SaldoTotale=SaldoTotale+_saldo
     WHERE Cliente=_cliente;
     
	END ;
    END LOOP;
    
    close Partecipanti ;
    
    
END $$
DELIMITER ;






DROP PROCEDURE IF EXISTS ProponiAlternativa;
DELIMITER $$
CREATE PROCEDURE ProponiAlternativa ( IN _Codprenotazione CHAR(30),IN _DataAlternativa DATE,
IN _OrarioInizioAlternativo TIME , IN _OrarioFineAlternativo TIME )
BEGIN
     
     INSERT INTO prenotazionealternativa
     VALUES(_codprenotazione,_dataalternativa,_orarioinizioalternativo,_orariofinealternativo,current_timestamp);
END $$
DELIMITER ;

DROP PROCEDURE IF EXISTS ProponiTreAlternative;
DELIMITER $$
CREATE PROCEDURE ProponiTreAlternative (  IN _Codprenotazione CHAR(30),
IN _DataAlternativa1 DATE,IN _OrarioInizioAlternativo1 TIME , IN _OrarioFineAlternativo1 TIME ,
IN _DataAlternativa2 DATE,IN _OrarioInizioAlternativo2 TIME , IN _OrarioFineAlternativo2 TIME ,
IN _DataAlternativa3 DATE,IN _OrarioInizioAlternativo3 TIME , IN _OrarioFineAlternativo3 TIME )
BEGIN
  declare _stato char(30) default ' ';
  declare _controllo1 char(30) default ' ';
  declare _controllo2 char(30) default ' ';
  declare _controllo3 char(30) default ' ';
  declare _area char(20) default ' ';
  
   set _stato=(select stato
                 from prenotazione
                 where codprenotazione=_codprenotazione);
	 
     IF _stato<>"alternativa" THEN
       SIGNAL SQLSTATE '45000'
       SET MESSAGE_TEXT="Non puoi proporre alternative a questa prenotazione";
	 END IF;
     
     set _area=(select area
                from prenotazione
                where codprenotazione=_codprenotazione);
     
     set _controllo1 = ControlloDisponibilitàArea(_area,_dataalternativa1,_orarioinizioalternativo1,
                                                 _orariofinealternativo1);
	 
     IF _controllo1="occupata" THEN
     BEGIN
       delete from prenotazionealternativa
       where codprenotazione=_codprenotazione;
       
       SIGNAL SQLSTATE '45000'
       SET MESSAGE_TEXT=" Alternativa 1 non valida,riprova";
	 END ;
	 END IF;
     
     
      set _controllo2 = ControlloDisponibilitàArea(_area,_dataalternativa2,_orarioinizioalternativo2,
                                                 _orariofinealternativo2);
	 
     IF _controllo2="occupata" THEN
     BEGIN
       delete from prenotazionealternativa
       where codprenotazione=_codprenotazione;
       
       SIGNAL SQLSTATE '45000'
       SET MESSAGE_TEXT=" Alternativa 2 non valida,riprova";
	 END ;
	 END IF;
     
     set _controllo3 = ControlloDisponibilitàArea(_area,_dataalternativa3,_orarioinizioalternativo3,
                                                 _orariofinealternativo3);
	 
     IF _controllo3="occupata" THEN
     BEGIN
       delete from prenotazionealternativa
       where codprenotazione=_codprenotazione;
       
       SIGNAL SQLSTATE '45000'
       SET MESSAGE_TEXT=" Alternativa 3 non valida,riprova";
	 END ;
	 END IF;
     
      CALL ProponiAlternativa(_codprenotazione,_dataalternativa1,_orarioinizioalternativo1,_orariofinealternativo1);
  CALL ProponiAlternativa(_codprenotazione,_dataalternativa2,_orarioinizioalternativo2,_orariofinealternativo2);
  CALL ProponiAlternativa(_codprenotazione,_dataalternativa3,_orarioinizioalternativo3,_orariofinealternativo3);
END $$
DELIMITER ;



DROP PROCEDURE IF EXISTS ConfermaAlternativa;
DELIMITER $$
CREATE PROCEDURE ConfermaAlternativa(IN _Codprenotazione CHAR(30),IN _DataAlternativa DATE,
IN _OrarioInizioAlternativo TIME , IN _OrarioFineAlternativo TIME )
BEGIN
  IF NOT EXISTS ( select *
				  from prenotazionealternativa
                  where CodPrenotazione=_codprenotazione
                        AND
                        DataAlternativa=_dataalternativa
                        AND
                        OrarioInizioAlternativo=_orarioinizioalternativo
                        AND
                        OrarioFineAlternativo=_orariofinealternativo) THEN
                        
	SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT="Nessuna delle alternative corrisponde";
 END IF;
 
  UPDATE prenotazione
  SET Dataattivita=_Dataalternativa,InizioAttivita=_OrarioInizioalternativo,
      FineAttivita=_orariofinealternativo,stato="approvata"
  WHERE CodPrenotazione=_codprenotazione;
  
  delete from prenotazionealternativa
  where codprenotazione=_codprenotazione;
END $$
DELIMITER ;


DROP PROCEDURE IF EXISTS InserisciIngresso_Pagato;
DELIMITER $$
CREATE PROCEDURE InserisciIngresso_Pagato (IN _Cliente VARCHAR(50), IN _DataAccesso DATE, IN _OrarioAccesso TIME,
										   IN _Sala VARCHAR(20))
BEGIN 
   
   DECLARE _Tipologia VARCHAR(25) DEFAULT '';
   DECLARE _Priorita INT DEFAULT 0;
   DECLARE _PrioritaSala INT DEFAULT 0;
   DECLARE _AccessoPiscina BOOL DEFAULT 0;
   DECLARE _Contratto VARCHAR(25) DEFAULT '';
   DECLARE Centro_Sala VARCHAR(20) DEFAULT '';
   DECLARE MaxIngressi INT DEFAULT 0;
   
  SELECT CodContratto,Tipologia INTO _Contratto,_Tipologia
  FROM Contratto
  WHERE Cliente=_Cliente
   AND  _DataAccesso BETWEEN DataSottoscrizione AND( DataSottoscrizione + INTERVAL DuratainMesi MONTH );
   
  IF (_Contratto IS NOT NULL AND _Contratto<>'') THEN 
  
     BEGIN
       
       IF (_Tipologia='Personalizzato') THEN
          BEGIN 
		    IF (_Sala IN (SELECT CodSala FROM Sala WHERE TipoSala<>'Piscina')) THEN
             BEGIN 
             
              SELECT Centro,AbbonamentoMinimo INTO Centro_Sala,_PrioritaSala
              FROM Sala
              WHERE CodSala=_Sala;
              
              SELECT Priorita INTO _Priorita
              FROM AbbonamentoPersonalizzato
              WHERE Centro=Centro_Sala
               AND Contratto=_Contratto;
               
			      IF (_Priorita<_PrioritaSala) THEN
               
                     INSERT INTO Log_AccessoPagato
                     VALUES (_Cliente,_Sala,_DataAccesso,_OrarioAccesso);
            
			      ELSE
                     SIGNAL SQLSTATE '45000'
                     SET MESSAGE_TEXT='Il cliente ha già il permesso per entrare';
			      END IF;
               END ;
			 ELSE
			   BEGIN
                 SELECT Centro INTO Centro_Sala
				 FROM Sala
                 WHERE CodSala=_Sala;
               
                 SELECT AccessoPiscine, NumeroMaxIngressoPiscineMese INTO _AccessoPiscina,MaxIngressi
                 FROM AbbonamentoPersonalizzato
                 WHERE Centro=Centro_Sala
				 AND Contratto=_Contratto;
               
			        IF (_AccessoPiscina=0 OR (_AccessoPiscina=1 AND MaxIngressi<(SELECT COUNT(*) FROM AccessoSala
																				 WHERE Sala=_Sala
																				 AND YEAR(_DataAccesso)=YEAR(DataAccesso)
                                                                                 AND MONTH(_DataAccesso)=MONTH(DataAccesso)))) THEN
               
                      INSERT INTO Log_AccessoPagato
                      VALUES (_Cliente,_Sala,_DataAccesso,_OrarioAccesso);
			   
                    ELSE 
                 
                      SIGNAL SQLSTATE '45000'
					  SET MESSAGE_TEXT='Il cliente ha gia il permesso per entrare in piscina';
			   
                    END IF;
               
			     END;
		      END IF;
			END;
		ELSE 
           BEGIN 
		    IF (_Sala IN (SELECT CodSala FROM Sala WHERE TipoSala<>'Piscina')) THEN
              BEGIN
               SELECT AbbonamentoMinimo INTO _PrioritaSala
			   FROM Sala
               WHERE CodSala=_Sala;
              
              SELECT Priorita INTO _Priorita
              FROM AbbonamentoStandard
              WHERE NomeAbbonamento=_Tipologia;
               
			     IF (_Priorita<_PrioritaSala) THEN
               
                   INSERT INTO Log_AccessoPagato
                   VALUES (_Cliente,_Sala,_DataAccesso,_OrarioAccesso);
            
			     ELSE
                    SIGNAL SQLSTATE '45000'
                    SET MESSAGE_TEXT='Il cliente ha già il permesso per entrare';
			      END IF;
               END ;
			 ELSE 
              BEGIN
               SELECT Centro INTO Centro_Sala
               FROM Sala
               WHERE CodSala=_Sala;
              
               SELECT AccessoPiscine,MaxNumeroIngressiSettimanali INTO _AccessoPiscina,MaxIngressi
               FROM AbbonamentoStandard
               WHERE NomeAbbonamento=_Tipologia;
               
			     IF (_AccessoPiscina=0  OR (_AccessoPiscina=1 AND MaxIngressi<(SELECT COUNT(*) FROM AccessoSala
																				 WHERE Sala=_Sala
																				 AND YEAR(_DataAccesso)=YEAR(DataAccesso)
                                                                                 AND MONTH(_DataAccesso)=MONTH(DataAccesso)))) THEN
               
                   INSERT INTO Log_AccessoPagato
                   VALUES (_Cliente,_Sala,_DataAccesso,_OrarioAccesso);
			   
                 ELSE 
                 
                   SIGNAL SQLSTATE '45000'
                   SET MESSAGE_TEXT='Il cliente ha gia il permesso per entrare in piscina';
			   
                 END IF;
               
			    END;
		   END IF;
		 END ;
	   END IF;
	 END ;
	 ELSE
      INSERT INTO Log_AccessoPagato
	  VALUES (_Cliente,_Sala,_DataAccesso,_OrarioAccesso);
	END IF;
END $$
DELIMITER ;
          
          
	      
           
          
   
   



DROP PROCEDURE IF EXISTS InserisciUscita_Pagato;
DELIMITER $$
CREATE PROCEDURE InserisciUscita_Pagato (IN _Cliente VARCHAR(16), IN _Sala VARCHAR(20),IN _OrarioUscita TIME)
BEGIN

DECLARE _DataAccesso DATE;
DECLARE _OrarioIngresso TIME ;
    
    
IF (EXISTS (SELECT * 
            FROM Log_AccessoPagato 
            WHERE Cliente=_Cliente 
             AND Sala=_Sala))     THEN
BEGIN 
  IF (_Sala IN (SELECT CodSala FROM Sala)) THEN 
   BEGIN 
   SELECT TariffaAccessoSingolo INTO @Tariffa
   FROM Sala
   WHERE CodSala=_Sala;
  
   SELECT OrarioAccesso,DataAccesso INTO _OrarioIngresso,_DataAccesso
   FROM Log_AccessoPagato
   WHERE Cliente=_Cliente AND Sala=_Sala;
  
   SET @ImportodaPagare=@Tariffa*((TIME_TO_SEC(_OrarioUscita)-TIME_TO_SEC(_OrarioIngresso))/3600);
  
   INSERT INTO Accesso_Pagato 
   VALUES (_Cliente,_Sala,@ImportodaPagare,_DataAccesso,_OrarioIngresso,_OrarioUscita);
  
    END ;
  ELSE 
 
     SIGNAL SQLSTATE '45000'
     SET MESSAGE_TEXT='Il cliente non ha accessi da pagare';
  
  END IF;
  END;
ELSE 
  
  SIGNAL SQLSTATE '45000'
  SET MESSAGE_TEXT='Il cliente non ha accessi da pagare';

END IF;
END $$
DELIMITER ;  
  
  
 DROP PROCEDURE IF EXISTS RegistraAccesso_SalaMedica;
 DELIMITER $$
 CREATE PROCEDURE RegistraAccesso_SalaMedica(IN _Cliente CHAR(16), IN _Centro CHAR(50),IN _DataAccesso DATE, IN _OrarioAccesso TIME)
 BEGIN
 
    IF NOT EXISTS (SELECT * FROM Contratto WHERE _Cliente=Cliente 
                   AND _DataAccesso BETWEEN DataSottoscrizione AND DataSottoscrizione + INTERVAL DuratainMesi MONTH) THEN 
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT ='Il cliente non ha contratto valido';
    END IF;
    
   INSERT INTO Log_SalaMedica
   VALUES (_Cliente,_Centro,_DataAccesso,_OrarioAccesso);
   
END $$
DELIMITER ;


DROP PROCEDURE IF EXISTS RegistraUscita_SalaMedica;
DELIMITER $$
CREATE PROCEDURE RegistraUscita_SalaMedica (IN _Cliente CHAR(16), IN _OrarioUscita TIME)
BEGIN 

  DECLARE _DataAccessoSala DATE;
  DECLARE _OrarioAccesso TIME;
  DECLARE _Centro CHAR(20) DEFAULT '';
  
  SELECT Centro,DataAccesso,OrarioAccesso INTO _Centro,_DataAccessoSala,_OrarioAccesso
  FROM Log_SalaMedica
  WHERE Cliente=_Cliente;
  
  INSERT INTO AccessoSala_Medica 
  VALUES (_Cliente,_Centro,_DataAccessoSala,_OrarioAccesso,_OrarioUscita);
  
  DELETE 
  FROM Log_SalaMedica
  WHERE Cliente=_Cliente;
  
END $$
DELIMITER ;
 
    
    
DROP PROCEDURE IF EXISTS AderisciSfida;
DELIMITER $$
CREATE PROCEDURE AderisciSfida (IN _Username VARCHAR(60), IN _Sfida VARCHAR(20),IN _DataIscrizione DATE)
BEGIN
  
  DECLARE ProponenteSfida VARCHAR(60) DEFAULT '';
  
  SELECT UtenteProponente INTO ProponenteSfida
  FROM Sfida
  WHERE CodSfida=_Sfida;
  
  IF (NOT EXISTS (SELECT *
                  FROM Amicizia
                  WHERE (Utente1=_Username AND Utente2=ProponenteSfida)
                   OR (Utente2=_Username AND Utente1=ProponenteSfida))) THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT='Il proponente non è tra i tuoi amici';
  END IF;
  
  IF NOT EXISTS (SELECT CodSfida
                 FROM Sfida
				 WHERE _Sfida=CodSfida
                  AND _DataIscrizione>=DataLancioSfida
                  AND _DataIscrizione<DataInizioSfida) THEN
  
   SIGNAL SQLSTATE '45000'
   SET MESSAGE_TEXT='Tempo di iscrizione per la sfida esaurito';
  END IF;
  
  INSERT INTO AderisciSfida
  VALUES(_Username,_Sfida);
  

END $$
DELIMITER ;

  
 

 DROP PROCEDURE IF EXISTS AnalisiPerformanceEsercizioAerobico ;
DELIMITER $$
CREATE PROCEDURE AnalisiPerformanceEsercizioAerobico (IN _cliente CHAR(16), IN _esercizio CHAR(10),
IN _IstanteInizio TIMESTAMP,IN _schedaallenamento CHAR(20), IN _Durata INT , IN _Recupero INT ,
 IN _GiornoScheda INT) 
BEGIN
     declare _finito INT default 0;
     declare _durataOtt INT default 0;
     declare _recuperoOtt INT default 0;
     declare _attrezzatura CHAR(50) default ' ';
     declare _configurazioneExSvolto CHAR(80) default ' ';
     declare _valoreconfigurazione INT default 0;
     declare _valutazioneconfigurazione BOOL default TRUE;
     declare _valutazionetempi DOUBLE default 0.00;
     declare _valutazionerecupero DOUBLE default 0.00;
     declare _commentoconfigurazione CHAR(50) default ' ';
     declare _commentotempi CHAR(50) default ' ';
     declare _commentorecupero CHAR(50) default ' '; 
     declare _conta INT default 0;
     
/* configurazione */
     declare ControllaConfigurazione cursor for
     (select Attrezzatura,TipoConfigurazione,ValoreConfigurazione
	  from esercizio_configurazione
      where esercizio=_esercizio);
            
	 declare continue handler for not found set _finito=1;
     
     IF NOT EXISTS (select *
                    from esercizioscheda
                    where esercizio=_esercizio
                          AND
                          giorno=_giornoscheda
                          AND
                          scheda=_schedaallenamento) THEN
		BEGIN
          insert into logperformance
          VALUES(current_timestamp,_cliente,"Esercizio non compatibile con la scheda" ,NULL,NULL,NULL);
          SIGNAL SQLSTATE '45000'
          SET MESSAGE_TEXT="Attenzione,inserito esercizio non valutabile";
		END;
	END IF;
    
 IF EXISTS (select *
				from esercizio_configurazione
                where
                    esercizio=_esercizio)           THEN
     
     open ControllaConfigurazione;
	
     
     Controlla : LOOP
	 BEGIN
       FETCH ControllaConfigurazione INTO _attrezzatura,_configurazioneexsvolto,_valoreconfigurazione;
       IF _finito=1 THEN
         LEAVE Controlla;
	   END IF;
       IF NOT EXISTS (select *
                  from eserciziosvolto_configurazione 
                  where esercizio=_esercizio
                        AND
                        attrezzatura=_attrezzatura
                        AND 
                        cliente=_cliente
                        AND
                        istanteinizio=_istanteinizio
                        AND
                        tipoconfigurazione=_configurazioneexsvolto
                        AND
                        valoreconfigurazione=_valoreconfigurazione) THEN
	    BEGIN
			set _valutazioneconfigurazione=FALSE;
            LEAVE Controlla;
	    END ;
		END IF;
     END;
	 END LOOP;
     
   close ControllaConfigurazione;
   
   IF (_valutazioneconfigurazione is TRUE) THEN 
     set _commentoconfigurazione="Configurazione con attrezzi corretta";
   END IF;
   IF _valutazioneconfigurazione is FALSE THEN 
     set _commentoconfigurazione="Configurazione con attrezzi errata";
   END IF;
   
ELSE 
  set _commentoconfigurazione="Esercizio senza attrezzi";
END IF;
   
   
    
   
   
 /* durata */
  
   set _durataOtt=(select DurataInMinuti
                   from esercizio
                   where codesercizio=_esercizio);
   
    CASE
   
   WHEN _durata BETWEEN (0.85*_durataOtt) AND (1.15*_durataOtt) THEN
     set _commentotempi="Ok,tempo relativamente giusto";
   WHEN _durata<(0.85*_durataOtt) THEN
     set _commentotempi="Attenzione,tempo inferiore all'ottimale";
   WHEN _durata>(1.15*_durataOtt) THEN
     set _commentotempi="Ottimo,tempo superiore all'ottimale";
	
   END CASE ;
   
/* recupero */
  
  set _recuperoOtt=(select TempodirecuperoSecondi
                    from esercizio
                    where codesercizio=_esercizio);
                    
  CASE
   
   WHEN _recupero BETWEEN (0.85*_recuperoOtt) AND (1.15*_recuperoOtt) THEN
     set _commentorecupero="Ok,tempo relativamente giusto";
   WHEN _recupero<(0.85*_recuperoOtt) THEN
     set _commentorecupero="Con calma,tempo inferiore all'ottimale";
   WHEN _recupero>(1.15*_recuperoOtt) THEN
     set _commentorecupero="Attenzione,tempo superiore all'ottimale";
	
   END CASE ;
   
   
   INSERT INTO LogPerformance
   VALUES (_istanteinizio,_cliente,_esercizio,_commentorecupero,_commentotempi,_commentoconfigurazione);

 
END $$
DELIMITER ;

DROP PROCEDURE IF EXISTS AnalisiPerformanceEsercizioAnaerobico ;
DELIMITER $$
CREATE PROCEDURE AnalisiPerformanceEsercizioAnaerobico (IN _cliente CHAR(16), IN _esercizio CHAR(10),
IN _IstanteInizio TIMESTAMP,IN _schedaallenamento CHAR(20), IN _ripetizioni INT ,IN _serie INT,
 IN _Recupero INT ,IN _GiornoScheda INT) 
BEGIN
     declare _finito INT default 0;
     declare _ripetizioniOtt INT default 0;
     declare _serieOtt INT default 0;
     declare _recuperoOtt INT default 0;
     declare _attrezzatura CHAR(50) default ' ';
     declare _configurazioneExSvolto CHAR(80) default ' ';
     declare _valoreconfigurazione INT default 0;
     declare _valutazioneconfigurazione BOOL default TRUE;
     declare _valutazionerecupero DOUBLE default 0.00;
     declare _commentoconfigurazione CHAR(80) default ' ';
     declare _commentoserie char(80) default 0;
     declare _commentorecupero CHAR(80) default ' ';  
     declare _ripetizionitot INT default 0;
     declare _ripetizioniOttTOT int default 0;
/* configurazione */
     
      declare ControllaConfigurazione cursor for
     (select Attrezzatura,TipoConfigurazione,ValoreConfigurazione
	  from esercizio_configurazione
      where esercizio=_esercizio);
            
	 declare continue handler for not found set _finito=1;
     
     IF NOT EXISTS (select *
                    from esercizioscheda
                    where esercizio=_esercizio
                          AND
                          giorno=_giornoscheda
                          AND
                          scheda=_schedaallenamento) THEN
		BEGIN
          insert into logperformance
          VALUES(current_timestamp,_cliente,"Esercizio non compatibile con la scheda" ,NULL,NULL,NULL);
          SIGNAL SQLSTATE '45000'
          SET MESSAGE_TEXT="Attenzione,inserito esercizio non valutabile";
		END;
	END IF;
    
 IF EXISTS (select *
				from esercizio_configurazione
                where
                    esercizio=_esercizio)           THEN
     
     open ControllaConfigurazione;
	
     
     Controlla : LOOP
	 BEGIN
       FETCH ControllaConfigurazione INTO _attrezzatura,_configurazioneexsvolto,_valoreconfigurazione;
       IF _finito=1 THEN
         LEAVE Controlla;
	   END IF;
       IF NOT EXISTS (select *
                  from eserciziosvolto_configurazione 
                  where esercizio=_esercizio
                        AND
                        attrezzatura=_attrezzatura
                        AND 
                        cliente=_cliente
                        AND
                        istanteinizio=_istanteinizio
                        AND
                        tipoconfigurazione=_configurazioneexsvolto
                        AND
                        valoreconfigurazione=_valoreconfigurazione) THEN
	    BEGIN
			set _valutazioneconfigurazione=FALSE;
            LEAVE Controlla;
	    END ;
		END IF;
     END;
	 END LOOP;
     
   close ControllaConfigurazione;
   
   IF (_valutazioneconfigurazione is TRUE) THEN 
     set _commentoconfigurazione="Configurazione con attrezzi corretta";
   END IF;
   IF _valutazioneconfigurazione is FALSE THEN 
     set _commentoconfigurazione="Configurazione con attrezzi errata";
   END IF;
   
ELSE 
  set _commentoconfigurazione="Esercizio senza attrezzi";
END IF;
   
   
 /* serie */

   set _serieOtt=(select numeroserie
                   from esercizio
                   where codesercizio=_esercizio);
                   
    set _ripetizioniOtt =(select numeroripetizioni
                          from esercizio
                          where codesercizio=_esercizio);
	
   set _ripetizionitot=_ripetizioni*_serie;
   set _ripetizioniOtttot=_serieOtt*_ripetizioniOtt;
   
   CASE
   
   WHEN _ripetizionitot BETWEEN (0.85*_ripetizioniOttTot) AND (1.15*_ripetizioniOttTot) THEN
     set _commentoserie="Ok,numero ripetizioni adeguato";
   WHEN _ripetizionitot<(0.85*_ripetizioniOttTot) THEN
     set _commentoserie="Attenzione,numero ripetizioni inferiore al richiesto";
   WHEN _ripetizionitot>(1.15*_ripetizioniOttTot) THEN
     set _commentoserie="Ottimo,numero ripetizioni superiore al richiesto";
	
   END CASE ;
   
   
/* recupero */
  
  set _recuperoOtt=(select TempodirecuperoSecondi
                    from esercizio
                    where codesercizio=_esercizio);
                    
  CASE
   
   WHEN _recupero BETWEEN (0.85*_recuperoOtt) AND (1.15*_recuperoOtt) THEN
     set _commentorecupero="Ok,tempo relativamente giusto";
   WHEN _recupero<(0.85*_recuperoOtt) THEN
     set _commentorecupero="Con calma,tempo inferiore all'ottimale";
   WHEN _recupero>(1.15*_recuperoOtt) THEN
     set _commentorecupero="Attenzione,tempo superiore all'ottimale";
	
   END CASE ;
   
     
   
   INSERT INTO LogPerformance
   VALUES (_istanteinizio,_cliente,_esercizio,_commentorecupero,_commentoserie,_commentoconfigurazione);

 
END $$
DELIMITER ;

DROP PROCEDURE IF EXISTS AggiungiEsercizioAerobico;
DELIMITER $$
CREATE PROCEDURE AggiungiEsercizioAerobico ( IN _codesercizio CHAR(10) , IN _Nome CHAR(50),
IN _dispendioenergeticomedio INT, IN _Durata INT , IN _TempoRecupero INT )
BEGIN 
  INSERT INTO Esercizio
  VALUES(_codesercizio,_nome,'aerobico',_dispendioenergeticomedio,_durata,NULL,NULL,_temporecupero);
END $$
DELIMITER ;


DROP PROCEDURE IF EXISTS AggiungiEsercizioAnaerobico;
DELIMITER $$
CREATE PROCEDURE AggiungiEsercizioAnaerobico ( IN _codesercizio CHAR(10) , IN _Nome CHAR(50),
IN _dispendioenergeticomedio INT, IN _NumeroRipetizioni INT , IN _NumeroSerie INT, IN _TempoRecupero INT )
BEGIN 
  INSERT INTO Esercizio
  VALUES(_codesercizio,_nome,'anaerobico',_dispendioenergeticomedio,NULL,_NumeroRipetizioni,_NumeroSerie,_temporecupero);
END $$
DELIMITER ;

/* così evito i trigger */

   

DROP PROCEDURE IF EXISTS AggiungiEsercizio_Svolto;
DELIMITER $$
CREATE PROCEDURE AggiungiEsercizio_Svolto(IN _Cliente VARCHAR(16), IN _Esercizio VARCHAR(20),IN _Istante TIMESTAMP,
                                          IN _SchedaAllenamento VARCHAR(20), IN _Ripetizioni INT ,IN _NumeroSerie INT,
                                          IN _Durata INT, IN _TempodiRecupero INT,IN _GiornoScheda INT,
                                          IN _Sfida VARCHAR(20))
BEGIN
  
  IF (NOT EXISTS (SELECT * FROM AccessoSala 
                  WHERE DataAccesso=DATE(_Istante)
                   AND Cliente=_Cliente
                   AND TIME(_Istante) BETWEEN OrarioAccesso AND OrarioUscita) AND
	  NOT EXISTS (SELECT * FROM Log_Sala
                  WHERE Cliente=_Cliente
                   AND OrarioAccesso<=TIME(_Istante))) THEN
	
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT='Errore, il cliente non ha eseguito accesso alla sala!';
  
  END IF;
  
  INSERT INTO EsercizioSvolto
  VALUES (_Cliente,_Esercizio,_Istante,_SchedaAllenamento,_Ripetizioni,_NumeroSerie,_Durata,_TempodiRecupero,_GiornoScheda, _Sfida);
         
END $$
DELIMITER ;





DROP PROCEDURE IF EXISTS AggiungiConfigurazione_EsercizioSvolto;
DELIMITER $$
CREATE PROCEDURE AggiungiConfigurazione_EsercizioSvolto(IN _Cliente VARCHAR(16), IN _Esercizio VARCHAR(20),IN _Istante TIMESTAMP,
                                          IN _Attrezzatura VARCHAR(20), IN _TipoConfigurazione VARCHAR(80) ,IN _Valore INT)
BEGIN
  
  
  SET @SalaAttrezzatura='';
  
SELECT Sala INTO @SalaAttrezzatura
FROM Attrezzatura
WHERE CodAttrezzatura=_Attrezzatura;

IF NOT EXISTS (SELECT * FROM Log_Sala
               WHERE Cliente=_Cliente
                AND DataAccesso=DATE(_Istante)
                AND TIME(_Istante)>=OrarioAccesso
                AND Sala=@SalaAttrezzatura) 
   AND 
   NOT EXISTS (SELECT * FROM AccessoSala
               WHERE Cliente=_Cliente
                AND DataAccesso=DATE(_Istante)
                AND TIME(_Istante) BETWEEN OrarioAccesso AND OrarioUscita
                AND Sala=@SalaAttrezzatura) THEN
 BEGIN
	SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT='Errore di sistema, la sala non coincide';
   

 END ;
END IF;

INSERT INTO EsercizioSvolto_configurazione
VALUES (_Cliente,_Esercizio,_Istante,_Attrezzatura,_TipoConfigurazione,_Valore);
	
END $$
DELIMITER ;
                   

DROP PROCEDURE IF EXISTS InserisciPersonale;
DELIMITER $$
CREATE PROCEDURE InserisciPersonale(IN _CodFiscale VARCHAR(16), IN _Nome VARCHAR(80), IN _Cognome VARCHAR(80),
                                    IN _DataNascita DATE, IN _Sesso VARCHAR(1), IN _Residenza VARCHAR(80), IN _Indirizzo VARCHAR(80),
                                    IN _DocumentoRiconoscimento VARCHAR(10), IN _Telefono VARCHAR(12),
                                    IN _Ruolo VARCHAR(20))
BEGIN 
    
  IF (_Ruolo='Istruttore' OR _Ruolo='Medico' OR _Ruolo='Segreteria') THEN
  BEGIN
    INSERT INTO Personale
    VALUES (_CodFiscale,_Nome,_Cognome,_DataNascita,_Sesso,_Residenza,_Indirizzo,_DocumentoRiconoscimento,_Telefono);
    
    IF (_Ruolo='Istruttore') THEN 
      
        INSERT INTO Istruttore
        VALUES (_CodFiscale,_Nome,_Cognome,_DataNascita,_Sesso,_Residenza,_Indirizzo,_DocumentoRiconoscimento,_Telefono);
    
    ELSE IF (_Ruolo='Medico') THEN 
           
           INSERT INTO Medico
           VALUES (_CodFiscale,_Nome,_Cognome,_DataNascita,_Sesso,_Residenza,_Indirizzo,_DocumentoRiconoscimento,_Telefono);
           
		 ELSE IF (_Ruolo='Segreteria') THEN
           
                INSERT INTO Segreteria
                VALUES (_CodFiscale,_Nome,_Cognome,_DataNascita,_Sesso,_Residenza,_Indirizzo,_DocumentoRiconoscimento,_Telefono);
    
              END IF;
		 END IF;
	END IF;
 
  END;
  
  ELSE 
    
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT='Ruolo non esistente';
  
  END IF;

END $$
DELIMITER ;
    
    
    
  DROP PROCEDURE IF EXISTS InserisciAutorizzazioneStandard;
  DELIMITER $$
  CREATE PROCEDURE InserisciAutorizzazioneStandard(IN _Contratto VARCHAR(20), IN _Centro VARCHAR(25))
   BEGIN 
    DECLARE _TipologiaContratto VARCHAR(20) DEFAULT '';
    DECLARE PrezzoAbbonamento INT DEFAULT 0;
    DECLARE PrezzoAbbonamentoMese INT DEFAULT 0;
    
   
    SELECT Tipologia,ImportoTotale/DurataInMesi INTO _TipologiaContratto, PrezzoAbbonamentoMese
    FROM Contratto
    WHERE CodContratto=_Contratto;
    
      IF _TipologiaContratto='Personalizzato'THEN 
     SIGNAL SQLSTATE '45000'
     SET MESSAGE_TEXT='Contratto standard non esistente';
      END IF;
    
    SELECT Prezzo INTO PrezzoAbbonamento
	FROM AbbonamentoStandard 
    WHERE NomeAbbonamento=_TipologiaContratto;
    
    
    IF (PrezzoAbbonamentoMese/PrezzoAbbonamento)>=3 THEN 
       SIGNAL SQLSTATE '45000'
       SET MESSAGE_TEXT='Numero massimo autorizzazioni raggiunto';
	END IF;
    
    
     INSERT INTO AutorizzazioneCentro
      VALUES (_Contratto,_Centro);
      
      UPDATE Contratto
	  SET ImportoTotale=((ImportoTotale/DuratainMesi) + (PrezzoAbbonamento)) * DuratainMesi
	  WHERE CodContratto=_Contratto;

    
   
END $$
DELIMITER ;
    
    
 DROP PROCEDURE IF EXISTS InserisciPotenziamentoMuscolare;
 DELIMITER $$
 CREATE PROCEDURE InserisciPotenziamentoMuscolare (IN _Contratto VARCHAR(25), IN _Muscolo VARCHAR(50), IN _Livello VARCHAR(70))
 BEGIN 
 
  IF (_Livello<>'Lieve' AND _Livello<>'Moderato' AND _Livello<>'Elevato') THEN 
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT='Valore non valido';
  END IF;
  
  IF NOT EXISTS (SELECT * FROM Contratto WHERE CodContratto=_Contratto AND Scopo='Potenziamento Muscolare') THEN 
  
     SIGNAL SQLSTATE '45000'
     SET MESSAGE_TEXT='Contratto non esistente';
  END IF;
  
  INSERT INTO PotenziamentoMuscolare
  VALUES (_Contratto, _Muscolo, _Livello);
  
END $$
DELIMITER ;



DROP PROCEDURE IF EXISTS AggiungiAutorizzazionePersonalizzata;
DELIMITER $$
CREATE PROCEDURE AggiungiAutorizzazionePersonalizzata (IN _Contratto VARCHAR(20), IN _Centro VARCHAR(20),
													   IN _Priorita INT , IN _MaxNumeroIngressiSettimanali INT,
                                                       IN _AccessoPiscine BOOL, IN _NumeroMaxIngressoPiscineMese INT,
                                                       IN _PossibilitaFrequentazioneCorsi BOOL)
													  
BEGIN
    
    DECLARE Durata INT DEFAULT 0;
    
    IF (NOT EXISTS (SELECT * FROM Contratto 
		            WHERE CodContratto=_Contratto 
					AND Tipologia='Personalizzato')) THEN 
       SIGNAL SQLSTATE '45000'
       SET MESSAGE_TEXT='Contratto non esistente';
     END IF;
    
    IF (SELECT COUNT(*) FROM AutorizzazionePersonalizzata WHERE Contratto=_Contratto)>=3 THEN 
       SIGNAL SQLSTATE '45000'
       SET MESSAGE_TEXT='Numero massimo autorizzazioni raggiunto';
	END IF;
    
    INSERT INTO AutorizzazionePersonalizzata 
    VALUES (_Contratto, _Centro, _Priorita,_MaxNumeroIngressiSettimanali,_AccessoPiscine,_NumeroMaxIngressoPiscineMese,
			_PossibilitaFrequentazioneCorsi);
    
    
    SELECT DuratainMesi INTO Durata
    FROM Contratto
    WHERE CodContratto=_Contratto;
  
 UPDATE Contratto
 SET ImportoTotale=((10 *_MaxNumeroIngressiSettimanali)+(2 *_AccessoPiscine)+(1 *_NumeroMaxIngressoPiscineMese)+
             (2.5 *_Priorita)+
			 (5 *_PossibilitaFrequentazioneCorsi) + 8 + (ImportoTotale/Durata))* Durata
 WHERE CodContratto=_Contratto;
 

END $$
DELIMITER ;

DROP  PROCEDURE IF EXISTS AggiungiAllaCerchia;
DELIMITER $$
CREATE PROCEDURE AggiungiAllaCerchia (IN _Utente2 CHAR(60), IN _Cerchia CHAR(20))
BEGIN
   declare _utente1 CHAR(30) default ' ';
   
   set _utente1=(select utente
				 from cerchia
                 where codcerchia=_Cerchia);
  IF NOT EXISTS (select *
             from consigliati 
             where UtenteConsigliato=_utente2
                   AND
                   cerchia=_cerchia) THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT ="L'utente non può essere aggiunto alla cerchia";
  END IF;
  INSERT INTO composizionecerchia
  VALUES (_Cerchia,_Utente2);
  END $$
  DELIMITER ;
  
  DROP PROCEDURE IF EXISTS DisdiciPartecipazione;
DELIMITER $$
CREATE PROCEDURE DisdiciPartecipazione (IN _Cliente CHAR(30),IN  _CodPrenotazione CHAR(30))
BEGIN 
  declare _tipologiacontratto CHAR(30) default ' ';
  declare _sede               CHAR(20) default ' ';
  
  IF (select stato
      from prenotazione
      where CodPrenotazione=_codprenotazione) = "da confermare" THEN
      SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT =" La prenotazione è già stata inoltrata";
  END IF;
  
  
  IF _Cliente = (select clienterichiedente
                 from prenotazione
                 where codprenotazione=_codprenotazione) THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT="Il richiedente non può disdire";
 END IF;
 
 IF NOT EXISTS ( select *
				 from Partecipante
                 where codprenotazione=_codprenotazione
					   AND 
                       cliente=_cliente ) THEN
                       
			SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = "Cancellazione fallita, non sei iscritto";
 END IF;

 DELETE  FROM Partecipante
 WHERE Cliente=_cliente
        AND
	   codprenotazione=_codprenotazione;
       
 UPDATE Prenotazione
 SET NumPartecipanti=NumPartecipanti-1
 WHERE codprenotazione=_codprenotazione;
 
 SET _tipologiacontratto=TipologiaContrattoCliente(_Cliente,_sede);
 
 CASE
   
    WHEN _tipologiacontratto='silver' THEN
    
    UPDATE prenotazione
    SET PunteggioGruppo=PunteggioGruppo-10
    WHERE CodPrenotazione=_codprenotazione;
          
	WHEN _tipologiacontratto='gold' THEN
    
    UPDATE prenotazione
    SET PunteggioGruppo=PunteggioGruppo-15
    WHERE CodPrenotazione=_codprenotazione;
    
	
    WHEN _tipologiacontratto='platinum' THEN
    
	UPDATE prenotazione
    SET PunteggioGruppo=PunteggioGruppo-25
    WHERE CodPrenotazione=_codprenotazione;
    
    
	
     WHEN _tipologiacontratto='personalizzato' THEN
     
	UPDATE prenotazione
    SET PunteggioGruppo=PunteggioGruppo-20
    WHERE CodPrenotazione=_codprenotazione;
    
    

	WHEN _tipologiacontratto='senza contratto' THEN
     
	UPDATE prenotazione
    SET PunteggioGruppo=PunteggioGruppo-5
    WHERE CodPrenotazione=_codprenotazione;
    
    END CASE;
    
END $$
DELIMITER ;

DROP PROCEDURE IF EXISTS DecrementaCarrello;
DELIMITER $$
CREATE PROCEDURE DecrementaCarrello (IN _CodProdotto CHAR(30), 
                                     IN _Decremento INT)

BEGIN
  declare _quantita INT default 0;
  declare _codordine CHAR(30) default ' ';
  declare _stato CHAR(10)  default ' ';
  
  set _stato=(SELECT O.stato
                     FROM ordine O NATURAL JOIN acquisto A
                     WHERE codprodotto=_codprodotto);
  
  set _codordine =(SELECT codordine
		  FROM acquisto 
                              WHERE codprodotto=_codprodotto);
                   
  IF _stato='evaso' THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT="L'ordine è stato inviato";
  END IF;
  
  
  set _quantita = (SELECT quantita
	             FROM acquisto
                           WHERE codprodotto=_codprodotto);
                   
  IF _Decremento > _quantita THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT=" Lo slot non contiene una quantità simile";
  END IF;
  
  IF _Decremento = _quantita THEN
  
  DELETE FROM Acquisto
  WHERE CodProdotto=_codprodotto;
  
  END IF;
  
  IF _Decremento < _quantita THEN
  
  UPDATE acquisto
  SET quantita=quantita-_Decremento
  WHERE codprodotto=_codprodotto;
  END IF;
  
END $$
DELIMITER ;

DROP PROCEDURE IF EXISTS CalcoloScadenzaPiuProssima ;
DELIMITER $$
CREATE PROCEDURE CalcoloScadenzaPiuProssima (IN _Centro CHAR(20),IN _integratore CHAR(30),
                                             OUT _Lotto CHAR(200) , OUT _Giorni INT)
                                               
BEGIN  
      declare _finito INT default 0;
      declare _codprodotto char(30) default ' ';
      declare _datascadenza DATE;
      declare _magazzino char(20) default ' ';
      
       
       declare LottiScadenza cursor for 
       (SELECT M1.codprodotto,M1.datascadenza
       FROM MerceMagazzino M1
       WHERE  NOT EXISTS (select *
                                                from MerceMagazzino M2
                                                 where M2.DataScadenza<M1.DataScadenza 
                                                AND magazzino=_magazzino 
                                                AND integratore=_integratore)
	 AND magazzino=_magazzino
               AND integratore=_integratore);
	  
      declare continue handler for not found set _finito=1;
      
      set _Lotto='';
      set _Giorni=0;
      
      set _magazzino=(select codmagazzino
                      from magazzino
                      where centro=_centro);
		
	  open LottiScadenza ;
      
      Concatena : LOOP
           BEGIN
             FETCH LottiScadenza INTO _codprodotto,_datascadenza;
             IF _finito=1 THEN
               LEAVE Concatena;
			 END IF;
             SET _Lotto=CONCAT(_Lotto,' -  ',_codprodotto);
             SET _Giorni=DATEDIFF(_datascadenza,current_date);
			END ;
            END LOOP;
	  
      close LottiScadenza;

END $$
DELIMITER ;
DROP PROCEDURE IF EXISTS AggiornaReport ;
DELIMITER $$
CREATE PROCEDURE AggiornaReport (IN _Centro CHAR(20))
BEGIN
     declare _finito INT default 0;
     declare _tipologia CHAR(25) default ' ';
     declare _integratore CHAR(30) default ' ';
     declare _quantita INT default 0;
     declare _magazzino char(25) default ' ';
     declare _guadagnototale DOUBLE default 0.00;
     
     
     declare EsaminaVendite cursor for
     (select distinct integratore
      from inventariomagazzino
      where magazzino=_magazzino
      order by integratore);
      
      declare continue handler for not found set _finito=1;
      
      set _magazzino=(select codmagazzino
					  from magazzino
                      where centro=_centro);
      
      set @LottiScadenza='';
      set @giorniallascadenza=0;
      
      open EsaminaVendite;
      
      CreaReport : LOOP
      BEGIN
        FETCH EsaminaVendite INTO _integratore;
        IF _finito=1 THEN
          LEAVE CreaReport;
		END IF;
        set _quantita=(select SUM(quantita)
                       from log_venditeintegratori
                       where integratore=_integratore
                             AND
                             centro=_centro);
                       
        if _quantita IS NULL THEN
          set _quantita=0;
		end if; 
        
        set _guadagnototale=(select SUM(guadagno)
                             from log_venditeintegratori
                             where integratore=_integratore
                                   AND
                                   centro=_centro);
        
        set _tipologia=(select tipologia
                        from integratore
                        where NomeCommerciale=_integratore);
		CALL CalcoloScadenzaPiuProssima(_centro,_integratore,@LottiScadenza,@giorniallascadenza);
        INSERT INTO ReportIntegratori
        VALUES (_centro,_tipologia,_integratore,_quantita,_guadagnototale,@LottiScadenza,@giorniallascadenza);
	  END ;
      END LOOP ;
      
      close EsaminaVendite ;
      
END $$
DELIMITER ;

DROP PROCEDURE IF EXISTS SettaRank;
DELIMITER $$
CREATE PROCEDURE SettaRank()
BEGIN

 declare _finito INT default 0;
    declare _codprodotto char(30) default ' ';
    declare _datascadenza DATE;
    
    declare ProdottiMagazzino cursor for
    (select codprodotto,datascadenza
     from mercemagazzino
     where DATEDIFF(datascadenza,current_date)<=90);
     
     declare continue handler for not found
     set _finito=1;
     
    open ProdottiMagazzino;
    
    Ranking : LOOP
    BEGIN
    FETCH ProdottiMagazzino INTO _codprodotto,_datascadenza;
    IF _finito=1 THEN
      LEAVE Ranking;
	END IF;
    CASE
    
      WHEN DATEDIFF(_datascadenza,current_date)<=30 THEN
      
        UPDATE MerceMagazzino
        SET Rank='high'
        WHERE codprodotto=_codprodotto;
        
	  WHEN DATEDIFF(_datascadenza,current_date)<=60
           AND DATEDIFF(_datascadenza,current_date)>30 THEN
           
		UPDATE Mercemagazzino
        SET Rank='medium'
        WHERE codprodotto=_codprodotto;
        
	  WHEN DATEDIFF(_datascadenza,current_date)<=90 
		   AND DATEDIFF(_datascadenza,current_date)>60 THEN
           
		UPDATE MerceMagazzino
        SET Rank='low'
        WHERE codprodotto=_codprodotto;
        
	END CASE;
    END ;
    END LOOP;
    
    close ProdottiMagazzino;

END $$
DELIMITER ;

DROP PROCEDURE IF EXISTS StatoMerceInviata;
DELIMITER $$
CREATE PROCEDURE StatoMerceInviata (IN _codordine CHAR(30) )
BEGIN
  declare _statoMerce char(20) default ' ';
   
   SET _statoMerce=(select stato
                    from ordinievasi
                    where CodOrdine=_codOrdine);

  IF (_statoMerce = 'merce arrivata') THEN
     SIGNAL SQLSTATE '45000'
     SET MESSAGE_TEXT="La merce è già arrivata ed è in attesa di essere stipata";
   END IF;
  IF (_statoMerce = 'merce inviata') THEN
     SIGNAL SQLSTATE '45000'
     SET MESSAGE_TEXT="La merce è già stata inviata";
   END IF; 
   
   UPDATE OrdiniEvasi
   SET stato='merce inviata'
   WHERE codordine=_codordine;

END $$
DELIMITER ;

DROP PROCEDURE IF EXISTS StatoMerceArrivata;
DELIMITER $$
CREATE PROCEDURE StatoMerceArrivata (IN _codordine CHAR(30) )
BEGIN
   declare _statoMerce char(20) default ' ';
   
   SET _statoMerce=(select stato
                    from ordinievasi
                    where CodOrdine=_codOrdine);
   
   IF (_statoMerce <> 'merce inviata' ) AND (_statoMerce <> 'merce arrivata') THEN
     SIGNAL SQLSTATE '45000'
     SET MESSAGE_TEXT="La merce non è stata inviata";
   END IF;
   
   IF (_statoMerce = 'merce arrivata') THEN
     SIGNAL SQLSTATE '45000'
     SET MESSAGE_TEXT="La merce è già arrivata ed è in attesa di essere stipata";
   END IF;
   
   
   UPDATE OrdiniEvasi
   SET stato='merce arrivata'
   WHERE codordine=_codordine;

END $$
DELIMITER ;
