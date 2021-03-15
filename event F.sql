DROP EVENT IF EXISTS ControlloSottoscrizioneeRate;
DELIMITER $$
CREATE EVENT ControlloSottoscrizioneeRate
ON SCHEDULE EVERY 1 DAY 
STARTS '2017-11-17 21:15:00'
DO 
 BEGIN
   UPDATE Cliente C1 NATURAL JOIN (SELECT Co.CodContratto,C2.CodFiscale AS CodFiscale 
                                   FROM Contratto Co INNER JOIN Cliente C2 
                                   ON Co.Cliente=C2.CodFiscale 
                                   WHERE Date_add(Co.DataSottoscrizione, INTERVAL Co.DuratainMesi MONTH)=current_date()) As D
   SET C1.Abbonato=false,
       C1.TutorAttuale=NULL;
	
   UPDATE ProfiloSocial PS INNER JOIN  (SELECT Co.CodContratto,C2.CodFiscale AS CodFiscale 
										FROM Contratto Co INNER JOIN Cliente C2 
                                        ON Co.Cliente=C2.CodFiscale WHERE 
                                        Date_add(Co.DataSottoscrizione, INTERVAL Co.DuratainMesi MONTH)=current_date()) As D
   ON PS.ProfiloSocial=D.CodFiscale
   SET PS.Attivo=false;
   
   UPDATE Rata
   SET StatoPagamento='Scaduto'
   WHERE DataScadenza<=Current_date()
     AND StatoPagamento='Non ancora dovuto';
 END $$
 DELIMITER ;
       
       
       
DROP EVENT IF EXISTS ControlloFineSfide;
DELIMITER $$
CREATE EVENT ControlloFineSfide
ON SCHEDULE EVERY 1 MINUTE
STARTS '2017-11-21 20:50:00'
DO 
BEGIN
  CALL Set_Finito();
  
  CALL CalcoloPunteggio_Event();
  
  CALL Rank_Sfida(); 
  
  DELETE FROM Log_Conclusioni;
  DELETE FROM Log_Sfida;
END $$
DELIMITER ;


DROP EVENT IF EXISTS OrdineFallito;
DELIMITER $$
CREATE EVENT OrdineFallito 

ON SCHEDULE EVERY 1 DAY 
STARTS '2017-11-17 21:15:00'
DO 
 BEGIN
   declare _finito INT default 0;
   declare _dataconsegna date ;
   declare _codordine char(30) default ' ';
   
   declare ControllaOrdini cursor for
   (select CodOrdine,dataconsegnapreferita
    from ordinievasi);
    
    declare continue handler for not found set _finito=1;
    
    open ControllaOrdini;
    
    SCAN: LOOP
      BEGIN
        FETCH ControllaOrdini INTO _codordine,_dataconsegna;
        IF _finito=1 THEN
          LEAVE SCAN;
		END IF ;
        IF _dataconsegna<current_date THEN 
          UPDATE Ordinievasi
          SET stato='fallito'
          WHERE codordine=_codordine;
		END IF;
	  END ;
      END LOOP;
      
      close ControllaOrdini;
END $$ 
DELIMITER ;
  
  
DROP EVENT IF EXISTS ControllaAttrezzatura;
DELIMITER $$
CREATE EVENT ControllaAttrezzatura
ON SCHEDULE EVERY 1 MONTH
STARTS '2017-11-17 21:30:00'
DO
 BEGIN
 
	UPDATE Attrezzatura
    SET LivelloDiUsuraPercentuale=LivelloDiUsuraPercentuale+10;
    
    UPDATE Attrezzatura
    SET Funzionante=0
    WHERE LivelloDiUsuraPercentuale>=100;
    
    UPDATE Attrezzatura
    SET Funzionante=1
    WHERE LivelloDiUsuraPercentuale=0;
    
END $$
DELIMITER ;


DROP EVENT IF EXISTS EliminaDopo2Giorni;
DELIMITER $$
CREATE EVENT EliminaDopo2Giorni
ON SCHEDULE EVERY 1 MINUTE STARTS '2017-11-17 21:15:00'
DO
  BEGIN
  
     declare _giornipassati INT default 0 ;
     declare _datainoltro TIMESTAMP;
     declare _codprenotazione CHAR(30) default ' ';
     declare _finito INT default 0 ;
     
     declare ControllaProposteAlternative cursor for
     
     (select codprenotazione
      from prenotazione
      where stato="alternativa");
      
      declare continue handler for not found set _finito=1;
      
      open ControllaProposteAlternative;
      
      Controllo: LOOP
        BEGIN
        
          FETCH ControllaProposteAlternative INTO _codprenotazione;
          IF _finito=1 THEN
            LEAVE Controllo;
		  END IF;
          set _datainoltro=(select distinct DataInoltroPrenotazione
                            from prenotazionealternativa
                            where codprenotazione=_codprenotazione);
		  set _giornipassati=TIMESTAMPDIFF(DAY,datainoltro,current_timestamp);
          IF _giornipassati >=2 THEN
            delete from prenotazione
            where codprenotazione = _codprenotazione;
		  END IF;
		END;
        END LOOP;
END $$
DELIMITER ;


DROP EVENT IF EXISTS SvuotaSaldoMese;
DELIMITER $$
CREATE EVENT SvuotaSaldoMese 
ON SCHEDULE EVERY 1 MONTH STARTS '2017-11-17 21:15:00'
DO
BEGIN
  UPDATE saldoareeallestibilicliente
  SET SaldoMese=0;
END $$
DELIMITER ;

DROP EVENT IF EXISTS CalcolaRankMerce;
DELIMITER $$
CREATE EVENT CalcolaRankMerce 
ON SCHEDULE EVERY 1 DAY STARTS '2017-11-19 00:00:00'
DO
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

DROP EVENT IF EXISTS DeferredRefresh;
DELIMITER $$
CREATE EVENT DeferredRefresh
ON SCHEDULE EVERY 1 MONTH STARTS '2017-11-19 00:00:00'
DO
  BEGIN
     declare _finito INT default 0;
    declare _centro CHAR(20) default ' ';
    
    declare CentriFitness cursor for
    (select codcentro
     from centro);
     
     declare continue handler for not found set _finito=1;
     
     open CentriFitness;
     
     TRUNCATE TABLE reportintegratori;
     
     Aggiorna : LOOP
       BEGIN
         FETCH CentriFitness INTO _centro;
         IF _finito=1 THEN
           LEAVE Aggiorna;
		 END IF;
         CALL AggiornaReport(_centro);
	   END;
       END LOOP;
       
       close CentriFitness;
       
   TRUNCATE TABLE Log_VenditeIntegratori; 
       
    
END $$
DELIMITER ;