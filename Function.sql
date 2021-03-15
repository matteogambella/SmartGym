DROP FUNCTION IF EXISTS InteressiInComuneCerchia;
delimiter $$
CREATE FUNCTION InteressiInComuneCerchia (_utente char(60), _cerchia char(20))
RETURNS INT not deterministic  /* interessi di un utente si possono evolvere nel tempo */
BEGIN
  declare _containteressi int default 0;
  declare _interesse char(50) default ' ';
  declare _finito int default 0;
  declare _interessecerchia1 char(50) default ' ';
  declare _interessecerchia2 char(50) default ' ';
  declare _interessecerchia3 char(50) default ' ';
  
  declare InteressiTarget cursor for
  (select I.interesse
   from Interesse I
   where I.username=_utente);
   
   declare continue handler for not found set _finito=1;
   
   set _interessecerchia1=(select C.interesse1
                           from Cerchia C
                           where C.codcerchia=_cerchia);
                           
   set _interessecerchia2=(select C.interesse2
                           from Cerchia C
                           where C.codcerchia=_cerchia);
                           
   set _interessecerchia3=(select C.interesse3
                           from Cerchia C
                           where C.codcerchia=_cerchia);

   open InteressiTarget;
   
   Conta : LOOP
     fetch InteressiTarget into _interesse;
     if _finito=1 then
       leave Conta;
	 end if;
     IF (_interessecerchia1=_interesse)
        OR 
        (_interessecerchia2=_interesse)
        OR
        (_interessecerchia3=_interesse) THEN
	
     set _containteressi=_containteressi+1;
     end if;
     END LOOP;
     return(_containteressi);
END $$
delimiter ;


DROP FUNCTION IF EXISTS AssegnaSforzo;
 DELIMITER $$
 CREATE FUNCTION AssegnaSforzo (_Percentuale DOUBLE) 
 RETURNS INT DETERMINISTIC 
 
 BEGIN 
   DECLARE Voto INT DEFAULT 0;
 
  CASE 
       WHEN (_Percentuale=0) THEN
          SET Voto=0;  
  
       WHEN (_Percentuale>0 AND _Percentuale<20) THEN 
          SET Voto=5;
          
       WHEN (_Percentuale>=20 AND _Percentuale<40) THEN 
          SET Voto=4;
          
	   WHEN (_Percentuale>=40 AND _Percentuale<60) THEN 
          SET Voto=3;
          
	   WHEN (_Percentuale>=60 AND _Percentuale<80) THEN 
		  SET Voto=2;
          
	   WHEN (_Percentuale>=80 AND _Percentuale<=100) THEN
          SET Voto=1;
   ELSE
    BEGIN
    END;
          
   END CASE;
   
   RETURN Voto;
   
 END $$
 
 DELIMITER ;
 
 
 DROP FUNCTION IF EXISTS VotoGiorni;
 DELIMITER $$
 CREATE FUNCTION VotoGiorni(_DataInizio DATE, _DataFine DATE, _DataConclusione DATE)
 RETURNS INT DETERMINISTIC 
 BEGIN
  
   DECLARE GiorniFine INT DEFAULT 0;
   DECLARE GiorniTotali INT DEFAULT 0;
   DECLARE Percentuale DOUBLE DEFAULT 0.00;
   DECLARE Voto INT DEFAULT 0;
   
   SET GiorniFine=DATEDIFF(_DataConclusione,_DataInizio);
   SET GiorniTotali=DATEDIFF(_DataFine,_DataInizio);
   SET Percentuale=(GiorniFine/GiorniTotali)*100;
   
   CASE 
        WHEN (Percentuale=0) THEN
          SET Voto=0;

       WHEN (Percentuale>=0 AND Percentuale<20) THEN 
          SET Voto=5;
          
       WHEN (Percentuale>=20 AND Percentuale<40) THEN 
          SET Voto=4;
          
	   WHEN (Percentuale>=40 AND Percentuale<60) THEN 
          SET Voto=3;
          
	   WHEN (Percentuale>=60 AND Percentuale<80) THEN 
		  SET Voto=2;
          
	   WHEN (Percentuale>=80 AND Percentuale<=100) THEN
          SET Voto=1;
     ELSE
    BEGIN
    END;     
   END CASE;
   
   RETURN Voto;
   
END $$
DELIMITER ;


DROP FUNCTION IF EXISTS VotoMisurazioni;
 DELIMITER $$
 CREATE FUNCTION VotoMisurazioni(_ScopoRaggiunto INT, _ScopoOttimale INT )
 RETURNS INT DETERMINISTIC 
 BEGIN
  
   DECLARE _Percentuale DOUBLE DEFAULT 0.00;
   DECLARE Voto INT DEFAULT 0;
   
   SET _Percentuale=(_ScopoRaggiunto/_ScopoOttimale)*100;
   
   CASE 
       WHEN (_Percentuale=0) THEN
          SET Voto=0;
          
       WHEN (_Percentuale>0 AND _Percentuale<10) THEN 
          SET Voto=1;
          
       WHEN (_Percentuale>=10 AND _Percentuale<20) THEN 
          SET Voto=2;
          
	   WHEN (_Percentuale>=20 AND _Percentuale<30) THEN 
          SET Voto=3;
          
	   WHEN (_Percentuale>=30 AND _Percentuale<40) THEN 
		  SET Voto=4;
          
	   WHEN (_Percentuale>=40 AND _Percentuale<50) THEN
          SET Voto=5;
          
	   WHEN (_Percentuale>=50 AND _Percentuale<60) THEN 
          SET Voto=6;
          
       WHEN (_Percentuale>=60 AND _Percentuale<70) THEN 
          SET Voto=7;
          
	   WHEN (_Percentuale>=70 AND _Percentuale<80) THEN 
          SET Voto=8;
          
	   WHEN (_Percentuale>=80 AND _Percentuale<90) THEN 
		  SET Voto=9;
          
	   WHEN (_Percentuale>=90 AND _Percentuale<=100) THEN
          SET Voto=10;
    ELSE
    BEGIN
    END;     
          
   END CASE;
   
   RETURN Voto;
   
END $$
DELIMITER ;


     
     
	
  DROP FUNCTION IF EXISTS TipologiaContrattoCliente;
DELIMITER $$
CREATE FUNCTION TipologiaContrattoCliente (  _Cliente CHAR(50) ,_Sede CHAR(50)) RETURNS CHAR(30) NOT DETERMINISTIC
BEGIN
  declare _tipologiacontrattostandard CHAR(30) default ' ';
  declare _tipologiacontrattopersonalizzato CHAR(30) default ' ';
  
  
  
     SET _tipologiacontrattostandard= (SELECT C.Tipologia
									  FROM Contratto C INNER JOIN AutorizzazioneCentro AC
								      ON C.CodContratto=AC.Contratto
						              WHERE C.DataSottoscrizione=(SELECT Max(C2.DataSottoscrizione)
																  FROM Contratto C2
																  WHERE C.Cliente=C2.Cliente)
									  AND C.DataSottoscrizione + INTERVAL C.DuratainMesi MONTH>=Current_Date()
                                       AND AC.Centro=_Sede
                                       AND C.Cliente=_Cliente);
                       
	SET _tipologiacontrattopersonalizzato= (SELECT C.Tipologia
									        FROM Contratto C INNER JOIN AutorizzazionePersonalizzata AP
								            ON C.CodContratto=AP.Contratto
						                    WHERE C.DataSottoscrizione=(SELECT Max(C2.DataSottoscrizione)
																        FROM Contratto C2
																        WHERE C.Cliente=C2.Cliente)
									        AND C.DataSottoscrizione + INTERVAL C.DuratainMesi MONTH>=Current_Date()
                                            AND AP.Centro=_Sede
                                            AND C.Cliente=_Cliente);
                                            
	IF (_tipologiacontrattopersonalizzato IS NULL AND _tipologiacontrattostandard IS NULL) THEN
      
      RETURN 'senza contratto';
	
    ELSE IF _tipologiacontrattostandard IS NOT NULL THEN
        RETURN _tipologiacontrattostandard;
		 ELSE
          RETURN _tipologiacontrattopersonalizzato;
		  END IF;
	END IF;
END $$
DELIMITER ;   
        
     
     
DROP FUNCTION IF EXISTS ControlloDisponibilitàArea;
DELIMITER $$
CREATE FUNCTION ControlloDisponibilitàArea (_Area CHAR(20),_DataAttivita DATE , _InizioAttivita TIME,
                                            _FineAttivita TIME)
RETURNS CHAR(20) NOT DETERMINISTIC
BEGIN 
    declare _controllo char(20) default ' ';
    IF EXISTS (select codprenotazione
             from prenotazione
             where stato='approvata'
                   AND 
                   Area=_Area
                   AND
                   DataAttivita=_DataAttivita
                   AND
                   (
                   (InizioAttivita<=_InizioAttivita
                    AND
                    FineAttivita>=_FineAttivita)
                    OR
				   (InizioAttivita>=_InizioAttivita
                    AND
                    FineAttivita<=_FineAttivita)
                    OR
				   (InizioAttivita<_FineAttivita
                    AND
                    FineAttivita>=_FineAttivita)
                    OR
				   (InizioAttivita<=_InizioAttivita
					AND
                    FineAttivita>_InizioAttivita)))
                    /* controllo disponibilità area */   
                    
                    OR
                    
                    EXISTS 
                    
	           (select *
               from Prenotazionealternativa PA NATURAL JOIN Prenotazione P
               where P.area=_area
                     AND
                     PA.DataAlternativa=_DataAttivita
                   AND
                   (
                   (PA.OrarioInizioAlternativo<=_InizioAttivita
                    AND
                    PA.OrarioFineAlternativo>=_FineAttivita)
                    OR
				   (PA.OrarioInizioAlternativo>=_InizioAttivita
                    AND
                    PA.OrarioFineAlternativo<=_FineAttivita)
                    OR
				   (PA.OrarioInizioAlternativo<_FineAttivita
                    AND
                    PA.OrarioFineAlternativo>=_FineAttivita)
                    OR
				   (PA.OrarioInizioAlternativo<=_InizioAttivita
					AND
                    PA.OrarioFineAlternativo>_InizioAttivita)))
                     
    THEN
                    
			SET _controllo="occupata";
ELSE

SET _controllo="libera";

END IF;

RETURN _controllo;

END $$
DELIMITER ;




DROP FUNCTION IF EXISTS ScontoContratto;
DELIMITER $$
CREATE FUNCTION ScontoContratto(_tipocontratto CHAR(30))
RETURNS DOUBLE DETERMINISTIC
BEGIN
  CASE
    WHEN _tipocontratto="senza contratto" THEN
      RETURN 1;
	WHEN _tipocontratto="silver" THEN 
      RETURN 0.8;
	WHEN _tipocontratto="gold" THEN
      RETURN 0.6;
	WHEN _tipocontratto="personalizzato" THEN
      RETURN 0.4;
	WHEN _tipocontratto="platinum" THEN
      RETURN 0.2;
  END CASE;
END $$
DELIMITER ;



DROP FUNCTION IF EXISTS TrovaGiorno;
DELIMITER $$
CREATE FUNCTION TrovaGiorno(DataDaScoprire DATE)
RETURNS VARCHAR(10) DETERMINISTIC
BEGIN
 
 
  SET @Giorno=DAYNAME(DataDaScoprire);
  
  CASE 
       WHEN @Giorno='Monday' THEN
         
		  RETURN 'Monday';
	   
       WHEN @Giorno='Tuesday' THEN
         
		  RETURN 'Tuesday';
          
       WHEN @Giorno='Wednesday' THEN
         
		  RETURN 'Wednesday';
          
	   WHEN @Giorno='Thursday' THEN
         
		  RETURN 'Thursday';
          
          
	   WHEN @Giorno='Friday' THEN
         
		  RETURN 'Friday';
          
          
	   WHEN @Giorno='Satuday' THEN
         
		  RETURN 'Saturday';
          
       WHEN @Giorno='Sunday' THEN
          
          RETURN 'Sunday';
  END CASE;
  
  END $$
  DELIMITER ;
  
  
  DROP FUNCTION IF EXISTS ScontoRank;
DELIMITER $$
CREATE FUNCTION ScontoRank(_rank CHAR(10))
RETURNS DOUBLE DETERMINISTIC
BEGIN
  CASE
    WHEN _rank="high" THEN
    RETURN 0.5;
    WHEN _rank="medium" THEN 
    RETURN 0.75;
    WHEN _rank="low" THEN
    RETURN 0.9;
    WHEN _rank is NULL THEN
    RETURN 1;
  END CASE;
END $$
DELIMITER ;