DROP TRIGGER IF EXISTS ControllaCerchia;
delimiter $$
CREATE TRIGGER ControllaCerchia
BEFORE INSERT ON Cerchia
FOR EACH ROW
BEGIN
  IF new.interesse1 not in (select I.Interesse 
                              from interesse I
							  where I.username=new.utente) THEN
  signal sqlstate '45000'
  set message_text="Creazione cerchia negata: il primo interesse deve essere tra gli interessi
					del creatore della cerchia!";
  end if;
  IF new.interesse2 not in (select I.Interesse 
                              from interesse I
							  where I.username=new.utente) THEN
  signal sqlstate '45000'
  set message_text="Creazione cerchia negata: il secondo interesse deve essere tra gli interessi
					del creatore della cerchia!";
  end if;
  IF new.interesse3 not in (select I.Interesse 
                              from interesse I
							  where I.username=new.utente) THEN
  signal sqlstate '45000'
  set message_text="Creazione cerchia negata: il terzo interesse deve essere tra gli interessi
					del creatore della cerchia!";
  end if;
END $$
delimiter ;

DROP TRIGGER IF EXISTS ControllaInserimentoGiudizio;
delimiter $$
CREATE TRIGGER ControllaInserimentoGiudizio
BEFORE INSERT ON Giudizio
FOR EACH ROW
BEGIN
  IF new.VotoStelle <0 OR new.VotoStelle >5 THEN
	signal sqlstate '45000'
    set message_text="Inserimento giudizio non valido: il voto assegnato non è valido" ;
    END IF ;
END $$
delimiter ;  



DROP TRIGGER IF EXISTS AggiornaNumeroStelle;
delimiter $$
CREATE TRIGGER AggiornaNumeroStelle
AFTER INSERT ON Giudizio
FOR EACH ROW
BEGIN
    set @StellePrimaDelGiudizio=(select PS.NumeroStelleTotali
								 from profilosocial PS
                                      inner join
                                      postrisposta PR
                                      on
                                      PS.username=PR.username
                                 where PR.codpost=new.codpost);
    update profilosocial PS
           inner join
           postrisposta PR
           on
           PS.username=PR.username
	set PS.NumeroStelleTotali=PS.NumeroStelleTotali+new.VotoStelle,
        PR.NumeroStelleTotali=PR.NumeroStelleTotali+new.VotoStelle
    where codpost=new.codpost;
   CASE
    WHEN @stelleprimadelgiudizio<30 and
         (@stelleprimadelgiudizio + new.votostelle) >=30 then
	begin
         update profilosocial PS
                inner join
                postrisposta PR on
                PS.username=PR.username
         set PS.popolarita='Nuovoarrivato'
         where PR.codpost=new.codpost;
	end;
	WHEN @stelleprimadelgiudizio<200 and
         (@stelleprimadelgiudizio + new.votostelle) >=200 then
	begin
         update profilosocial PS
                inner join
                postrisposta PR on
                PS.username=PR.username
         set PS.popolarita='Conosciuto'
         where PR.codpost=new.codpost;
	end;
	WHEN @stelleprimadelgiudizio<500 and
         (@stelleprimadelgiudizio + new.votostelle) >=500 then
	begin
		 update profilosocial PS
                inner join
                postrisposta PR on
                PS.username=PR.username
         set PS.popolarita='Popolare'
         where PR.codpost=new.codpost;
	end;
	WHEN @stelleprimadelgiudizio<1000 and
        (@stelleprimadelgiudizio + new.votostelle) >=1000 then
	begin
         update profilosocial PS
                inner join
                postrisposta PR on
                PS.username=PR.username
         set PS.popolarita='Vip'
         where PR.codpost=new.codpost;
	end;
    ELSE BEGIN END;
    END CASE ; 
         
END $$
delimiter ;


DROP TRIGGER IF EXISTS AggiornaAreaForum1; 
DELIMITER $$
CREATE TRIGGER AggiornaAreaForum1
AFTER INSERT ON postprincipale
FOR EACH ROW
BEGIN
  UPDATE AreaForum
  SET    Dataultimopost=current_date,
         UtenteUltimoPost=new.username,
         UltimoPost=new.Codpost
  WHERE NomeArea=new.areaforum;
END $$
delimiter ; 


drop trigger if exists ControllaStato1;
delimiter $$
create trigger ControllaStato1
before insert on RichiestaAmicizia
for each row
begin
  if new.stato <> 'Da confermare' then
    signal sqlstate '45000'
    set message_text = 'Inserimento non valido : il valore assegnato a Stato non è valido' ;
  end if;
end $$
delimiter ;

 
drop trigger if exists  ControllaStato2;
delimiter $$
create trigger ControllaStato2
before update on RichiestaAmicizia
for each row
begin
  if old.stato = 'Da confermare'
    and (new.stato not in ('Rifiutata','Confermata')) then
      signal sqlstate '45000'
      set message_text='La richiesta va confermata o rifiutata,altri valori non sono ammessi';
  end if;
end $$
delimiter ;


drop trigger if exists RichiestaConfermata;
delimiter $$
create trigger RichiestaConfermata
after update on RichiestaAmicizia
for each row
begin
  if old.stato='Da confermare'
    and new.stato='Confermata' then
	  insert into Amicizia
      values(new.UtenteRichiedente,new.UtenteDestinatario,current_date);
  end if;
end $$
delimiter ;

drop trigger if exists AggiornaNumeroPostPubblicati1;
delimiter $$
create trigger AggiornaNumeroPostPubblicati1
after insert on postprincipale
for each row
begin
  update profilosocial
  set NumeroPostPubblicati=NumeroPostPubblicati + 1
  where username=new.username;
end $$
delimiter ;

drop trigger if exists AggiornaNumeroPostPubblicati2;
delimiter $$
create trigger AggiornaNumeroPostPubblicati2
after insert on postrisposta
for each row
begin
  update profilosocial
  set NumeroPostPubblicati=NumeroPostPubblicati+ 1
  where username=new.username;
end $$
delimiter ;


/*DROP TRIGGER IF EXISTS ImportoContratto;
DELIMITER $$
CREATE TRIGGER ImportoContratto
BEFORE INSERT ON Contratto
FOR EACH ROW
BEGIN
  SET new.ImportoTotale=new.DurataInMesi*(Select PrezzoAbbonamento From Abbonamento Where NomeAbbonamento=new.Tipologia);
END $$
 DELIMITER ;
*/

DROP TRIGGER IF EXISTS ControllaOrario;
DELIMITER $$
CREATE TRIGGER ControllaOrario
BEFORE INSERT ON Turnazione
FOR EACH ROW
BEGIN
  DECLARE OraInizio Time; 
  DECLARE OraFine Time;
  DECLARE TurniPrecedenti int DEFAULT 0;
  DECLARE OreGiornata INT DEFAULT 0;
  
  SELECT OrarioApertura,OrarioChiusura INTO OraInizio,OraFine 
  FROM OrarioAperturaCentro 
  WHERE new.Centro=Centro AND GiornoSettimana=new.GiornoSettimana;
  
  IF (new.InizioTurno>=OraInizio AND new.InizioTurno<OraFine) AND (new.FineTurno>OraInizio AND new.FineTurno<=OraFine) THEN
   BEGIN
   SET OreGiornata=((select SUM(to_seconds(FineTurno)-To_seconds(InizioTurno)) as Secondi
                     from Turnazione
					WHERE Dipendente=new.Dipendente
                       AND GiornoSettimana=new.GiornoSettimana) + (to_seconds(new.FineTurno)-To_seconds(new.InizioTurno)));
	 IF OreGiornata>28800 THEN
     SIGNAL SQLSTATE '45000'
     SET MESSAGE_TEXT='Inserimento non valido';
     ELSE
     BEGIN 
      
        
IF EXISTS (SELECT *
           FROM Turnazione
		   WHERE (Dipendente=new.Dipendente
           AND GiornoSettimana=new.GiornoSettimana)
           AND (((new.InizioTurno >InizioTurno AND new.InizioTurno<FineTurno) 
           OR (new.FineTurno >InizioTurno AND new.FineTurno<FineTurno))
           OR ((InizioTurno> new.InizioTurno AND InizioTurno< new.FineTurno) 
           OR (FineTurno >new.InizioTurno AND FineTurno<new.FineTurno)))) THEN
         
         SIGNAL SQLSTATE '45000'
         SET MESSAGE_TEXT='Inserimento non valido';
		END IF;
	  END;
      END IF;
	END;
 ELSE
    SIGNAL SQLSTATE '45000'
	SET MESSAGE_TEXT='Inserimento non valido';
 END IF;
END $$
 DELIMITER ;
 

 
 
  
  
DROP TRIGGER IF EXISTS GestisciConsigliati1;     
delimiter $$
CREATE TRIGGER GestisciConsigliati1
AFTER INSERT ON Amicizia
FOR EACH ROW
BEGIN
  CALL ConsigliaCerchia ( new.utente1,new.utente2);
  CALL ConsigliaCerchia (new.utente2,new.utente1);
END $$
DELIMITER ;



DROP TRIGGER IF EXISTS GestisciConsigliati2;
delimiter $$
CREATE TRIGGER GestisciConsigliati2
AFTER INSERT ON Interesse
FOR EACH ROW
BEGIN
  declare utente char(20) default ' ';
  declare cerchiatarget char(50) default ' ';
  declare finito int default 0;
  
  declare utenticerchietarget cursor for 
  (select C.utente,C.codcerchia
   from Cerchia C
        inner join 
        Amicizia A
        on
        C.utente=A.utente2
   where A.utente1=new.username
         and
		(C.interesse1=new.interesse
		 OR
         C.interesse2=new.interesse
         OR
         C.interesse3=new.interesse));
         
  declare continue handler for not found set finito=1;
  
  open utenticerchietarget;
  
  InserisciConsigliati : LOOP
    fetch utenticerchietarget into utente,cerchiatarget;
    if finito=1 then
      leave inserisciconsigliati;
	end if;
    insert into Consigliati
    values(new.username,cerchiatarget,Interessincomunecerchia(new.username,cerchiatarget));
    end loop;
    close utenticerchietarget;
end $$
delimiter ;



DROP TRIGGER IF EXISTS GestisciConsigliati3;
DELIMITER $$
CREATE TRIGGER GestisciConsigliati3
AFTER DELETE ON Amicizia
FOR EACH ROW 
BEGIN 

 CALL ConsigliaCerchia2 (old.Utente1,old.Utente2);
 CALL ConsigliaCerchia2 (old.Utente2,old.Utente1);

END $$
DELIMITER ;


DROP TRIGGER IF EXISTS GestisciConsigliati4;
delimiter $$
CREATE TRIGGER GestisciConsigliati4
AFTER DELETE ON Interesse
FOR EACH ROW
BEGIN
  declare utente char(20) default ' ';
  declare cerchiatarget char(50) default ' ';
  declare controllo int default 0;
  declare finito int default 0;
  
  declare utenticerchietarget cursor for 
  (select C.utente,C.codcerchia
   from Cerchia C
        inner join 
        Amicizia A
        on
        C.utente=A.utente2
   where A.utente1=old.username
         and
         C.interesse1=old.interesse
         or
         C.interesse2=old.interesse
         or
         C.interesse3=old.interesse);
         
  declare continue handler for not found set finito=1;
  
  open utenticerchietarget;
  
  RimuoviConsigliati : LOOP
    fetch utenticerchietarget into utente,cerchiatarget;
    if finito=1 then
      leave rimuoviconsigliati;
	end if;
    set controllo=InteressiInComuneCerchia(old.username,cerchiatarget);
    IF controllo=0 then 
    delete from Consigliati
    where utenteconsigliato=old.username
          and
          cerchia=cerchiatarget;
	else 
    update Consigliati
    set NumeroInteressiInComune=NumeroInteressiInComune - 1
    where cerchia=cerchiatarget
          and
          utenteconsigliato=old.username;
    end if;
	
    end loop;
    close utenticerchietarget;
end $$
delimiter ;




DROP TRIGGER IF EXISTS ControllaCorsi1;
DELIMITER $$
CREATE TRIGGER ControllaCorsi1
BEFORE INSERT ON Corso                              /* Il Trigger controlla il record prima di inserirlo (BEFORE) */
FOR EACH ROW
BEGIN

DECLARE GiaPresente INT DEFAULT 0;
DECLARE CentroI VARCHAR(10) DEFAULT '';
DECLARE Valido INT DEFAULT 0;
DECLARE Verifica INT DEFAULT 0;


IF NEW.NomeDisciplina NOT IN (SELECT Disciplina 
						      FROM TipologiaCorso_Sala T INNER JOIN Sala S 
								ON T.TipoSala=S.TipoSala 
							  WHERE S.CodSala=NEW.Sala) THEN
           SIGNAL SQLSTATE '45000'
           SET MESSAGE_TEXT='Disciplina non attinente al tipo sala o non esistente!';
          END IF;  
       
  
IF EXISTS(SELECT * 
		  FROM Corso                                       
          WHERE Istruttore=new.Istruttore
          AND FineCorso>NEW.InizioCorso
          AND Sala=new.Sala
          AND NomeDisciplina=new.NomeDisciplina
          AND LivelloInsegnamento=new.LivelloInsegnamento) THEN 
          
 SIGNAL SQLSTATE '45000'
 SET MESSAGE_TEXT='Corso già esistente!';
END IF;

SELECT Centro INTO CentroI
FROM  Sala 
WHERE CodSala=new.Sala;
  


IF NOT EXISTS(SELECT *
              FROM Turnazione                      
			  WHERE Dipendente=new.Istruttore
              AND Centro=CentroI) THEN 
 SIGNAL SQLSTATE '45000'
 SET MESSAGE_TEXT='Il tutor non lavora nel centro!';
END IF;
END $$
DELIMITER ;




DROP TRIGGER IF EXISTS ControllaCorsi2;
DELIMITER $$
CREATE TRIGGER ControllaCorsi2
BEFORE INSERT ON CalendarioLezioni
FOR EACH ROW
BEGIN 
 DECLARE ContaLezioni INT DEFAULT 0;
 DECLARE CentroI VARCHAR(10) DEFAULT '';
 DECLARE IstruttoreCorso VARCHAR(16) DEFAULT '';
 DECLARE Inizio TIME DEFAULT '';
 DECLARE Fine TIME DEFAULT '';
 DECLARE Lavora INT DEFAULT 0;
 DECLARE Sala_Istruttore VARCHAR(50) DEFAULT '';
  DECLARE ContaLezioni_AltriTutor INT DEFAULT 0;
 
 SELECT C.Istruttore INTO IstruttoreCorso
 FROM Corso C
 WHERE CodCorso=new.CodCorso;
 
 SELECT S.Centro,S.CodSala INTO CentroI,Sala_Istruttore
 FROM Sala S INNER JOIN Corso C
 ON S.CodSala=C.Sala
 WHERE C.CodCorso=NEW.CodCorso;
 
 SELECT InizioTurno,FineTurno,Count(*) INTO Inizio,Fine,Lavora
  FROM Turnazione
  WHERE Dipendente=IstruttoreCorso
   AND GiornoSettimana=new.GiornoSettimana
   AND Centro=CentroI
   AND (InizioTurno<=new.OrarioInizio AND InizioTurno<new.OrarioFine) AND (FineTurno>=new.OrarioFine AND FineTurno>new.OrarioInizio);
 
 IF (Lavora=0) THEN 
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT='Inserimento annullato, non in linea con il turno del tutor';
   END IF;
 
 
 
 SELECT COUNT(*) INTO ContaLezioni
 FROM CalendarioLezioni CL INNER JOIN Corso C
   ON C.CodCorso=CL.CodCorso
 WHERE (C.Sala=Sala_Istruttore
   AND CL.GiornoSettimana=new.GiornoSettimana)
   AND ((Inizio<=new.OrarioInizio AND Inizio<new.OrarioFine) AND (Fine>=new.OrarioFine AND Fine>new.OrarioInizio))
   AND (((CL.OrarioInizio<=new.OrarioInizio AND CL.OrarioFine>new.OrarioInizio) OR (CL.OrarioFine>=new.OrarioFine AND CL.OrarioFine>=new.OrarioInizio)) 
     OR (CL.OrarioInizio>=new.OrarioInizio AND CL.OrarioFine<new.OrarioFine));
 
   
   IF ContaLezioni>0 THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT='Inserimento annullato, non in linea con le altre lezioni dello stesso istruttore o altri tutor!';
   END IF;
   
   
 END $$
 DELIMITER ;
 
 
 DROP TRIGGER IF EXISTS ControllaTutor;
 DELIMITER $$
 CREATE TRIGGER ControllaTutor
 BEFORE INSERT ON SchedaAllenamento
 FOR EACH ROW
 BEGIN
 
  DECLARE CentroCliente VARCHAR(20) DEFAULT '';
  DECLARE Verifica INT DEFAULT 0;
  DECLARE OrarioAccesso_Cliente TIME;
  DECLARE GiornoEmissione_Cliente VARCHAR(20);
  
  
    SELECT Centro,DAYNAME(DataAccesso),OrarioAccesso INTO CentroCliente,GiornoEmissione_Cliente,OrarioAccesso_Cliente
    FROM AccessoCentro
    WHERE Cliente=NEW.Cliente
       AND DataAccesso=NEW.DataEmissione;
       
   IF (OrarioAccesso_Cliente IS NULL) THEN
     SIGNAL SQLSTATE '45000'
     SET MESSAGE_TEXT='Il cliente non è acceduto nel giorno inserito';
   END IF;
   
   
   
   IF NOT EXISTS ( SELECT *
                   FROM Turnazione
				   WHERE Dipendente=NEW.Tutor
                   AND GiornoSettimana=GiornoEmissione_Cliente
                   AND Centro=CentroCliente
                   AND OrarioAccesso_Cliente BETWEEN InizioTurno AND FineTurno)  THEN 
                   
     SIGNAL SQLSTATE '45000'
     SET MESSAGE_TEXT='Il tutor non lavora quel giorno';
   END IF;
    
END $$
DELIMITER ;
    
    
  
DROP TRIGGER IF EXISTS ControllaMedico;
 DELIMITER $$
 CREATE TRIGGER ControllaMedico
 BEFORE INSERT ON SchedaAlimentazione
 FOR EACH ROW
 BEGIN
 
  DECLARE CentroCliente VARCHAR(20) DEFAULT '';
  DECLARE Verifica INT DEFAULT 0;
  DECLARE OrarioAccesso_Cliente TIME;
  DECLARE GiornoEmissione_Cliente VARCHAR(20);
  
  
    SELECT Centro,DAYNAME(DataAccesso),OrarioAccesso INTO CentroCliente,GiornoEmissione_Cliente,OrarioAccesso_Cliente
    FROM AccessoSala_Medica
    WHERE Cliente=NEW.Cliente
       AND DataAccesso=NEW.DataEmissione;
      
 IF (OrarioAccesso_Cliente IS NULL ) THEN
   SIGNAL SQLSTATE '45000'
   SET MESSAGE_TEXT='Il cliente non è acceduto alla sala medica quel giorno!';
 END IF;
    
   
   IF NOT EXISTS (SELECT *
                  FROM Turnazione
                  WHERE Dipendente=NEW.Medico
                  AND GiornoSettimana=GiornoEmissione_Cliente
                  AND Centro=CentroCliente
                  AND OrarioAccesso_Cliente BETWEEN InizioTurno AND FineTurno) THEN
   
     SIGNAL SQLSTATE '45000'
     SET MESSAGE_TEXT='Il medico non lavora nel centro / quel giorno!';
   END IF;
    
END $$
DELIMITER ;
 
 
 DROP TRIGGER IF EXISTS ControllaConsulente;
 DELIMITER $$
 CREATE TRIGGER ControllaConsulente
 BEFORE INSERT ON Contratto
 FOR EACH ROW
 BEGIN 
 DECLARE Lavoro INT DEFAULT 0;
   
 
   
 IF NOT EXISTS(SELECT * 
               FROM Turnazione T
			   WHERE T.Dipendente=new.Consulente
			   AND DAYNAME(new.DataSottoscrizione)=T.GiornoSettimana
               AND T.Centro=new.SedeSottoscrizione) THEN 
  SIGNAL SQLSTATE '45000'
  SET MESSAGE_TEXT='Il/la consulente non lavora in quel giorno/centro';
 END IF;
 
 END $$
 DELIMITER ;
 

  
  
  
  DROP TRIGGER IF EXISTS ControlloRateizzazione;
  DELIMITER $$
  CREATE TRIGGER ControlloRateizzazione
  BEFORE INSERT ON Rateizzazione
  FOR EACH ROW 
  BEGIN 
  
  IF new.Contratto IN (SELECT CodContratto FROM Contratto WHERE CodContratto=new.Contratto  AND ModPagamento='Dilazionato') THEN 
    BEGIN 
     IF new.Contratto IN (SELECT Contratto FROM Rateizzazione) THEN
       SIGNAL SQLSTATE '45000'
	   SET MESSAGE_TEXT ='Rateizzazione del contratto gia presente nel database!';
	 END IF;
	END;
  ELSE
   SIGNAL SQLSTATE '45000'
   SET MESSAGE_TEXT ='Contratto con pagamento non dilazionato!';
  END IF;
  
  END $$
  DELIMITER ;
  
  
  
  DROP TRIGGER IF EXISTS ControllaRate;
  DELIMITER $$
  CREATE TRIGGER ControllaRate
  BEFORE INSERT ON Rata
  FOR EACH ROW
  BEGIN
   DECLARE ContoRate INT DEFAULT 0;
   DECLARE RateTotali INT DEFAULT 0;
   DECLARE DataScadenzaUltimaRata DATE;
   DECLARE Interesse INT DEFAULT 0;
   DECLARE ImportoContratto INT DEFAULT 0;
   DECLARE Contratto_Cliente VARCHAR(50) DEFAULT '';
   
   SELECT COUNT(*) INTO ContoRate
   FROM Rata
   WHERE Rateizzazione=new.Rateizzazione;
   
   SELECT NumeroRate,TassoInteressePercentuale,Contratto INTO RateTotali,Interesse,Contratto_Cliente
   FROM Rateizzazione
   WHERE CodRateizzazione=new.Rateizzazione;
   
   IF ContoRate>=RateTotali THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT ='Numero di rate massimo raggiunto per quel contratto';
   END IF;
   
  IF (RateTotali<>0) THEN
    BEGIN
    SELECT MAX(R.DataScadenza) INTO DataScadenzaUltimaRata
    FROM Rata R
    WHERE R.Rateizzazione=new.Rateizzazione;
    
    
    
    IF (period_diff(date_format(new.DataScadenza,'%Y%m'),date_format(DataScadenzaUltimaRata,'%Y%m'))<>12/RateTotali) THEN
     SIGNAL SQLSTATE '45000'
     SET MESSAGE_TEXT ='Periodo tra le due date non valido! ';
     END IF;
    END;
  END IF;
  
    IF (new.StatoPagamento<>'Eseguito' AND new.StatoPagamento<>'Non ancora dovuto' AND new.StatoPagamento<>'Scaduto') THEN
     SIGNAL SQLSTATE '45000'
     SET MESSAGE_TEXT ='Valore non valido nel campo StatoPagamento! ';
     END IF;
     
   
   SELECT ImportoTotale INTO ImportoContratto
   FROM Contratto
   WHERE CodContratto=Contratto_Cliente;
   
   SET NEW.Importo=(ImportoContratto/RateTotali)*((100 + Interesse)/100);
   
   END $$
   DELIMITER ;
   
 /*  
   DROP TRIGGER  IF EXISTS InserimentoPersonale;
  DELIMITER $$
  CREATE TRIGGER InserimentoPersonale 
  BEFORE INSERT ON Personale
  FOR EACH ROW
  BEGIN 
  
  IF (new.Ruolo<>'Tutor' AND new.Ruolo<>'Medico' AND new.Ruolo<>'Segreteria') THEN
   SIGNAL SQLSTATE '45000'
   SET MESSAGE_TEXT='Ruolo non valido!';
  END IF;
  
  END $$
  DELIMITER ;
  
  
  DROP TRIGGER IF EXISTS InserimentoSchedaAlim;
  DELIMITER $$
  CREATE TRIGGER InserimentoSchedaAlim
  BEFORE INSERT ON SchedaAlimentazione
  FOR EACH ROW
  BEGIN 
  
  IF new.Medico NOT IN (SELECT CodFiscale FROM Personale WHERE Ruolo='Medico') THEN 
   SIGNAL SQLSTATE '45000'
   SET MESSAGE_TEXT='Il dipendente che si sta inserendo non è un medico';
  END IF;

  END $$
  DELIMITER ;
  


/*
   DROP TRIGGER IF EXISTS InserimentoSchedaAllenamento;
  DELIMITER $$
  CREATE TRIGGER InserimentoSchedaAllenamento
  BEFORE INSERT ON SchedaAllenamento
  FOR EACH ROW
  BEGIN 
  
  IF new.Tutor NOT IN (SELECT CodFiscale FROM Personale WHERE Ruolo='Tutor') THEN 
   SIGNAL SQLSTATE '45000'
   SET MESSAGE_TEXT='Il dipendente che si sta inserendo non è un Tutor';
  END IF;

  END $$
  DELIMITER ;
  
  
  
  DROP TRIGGER IF EXISTS AggiornamentoCliente;
  DELIMITER $$
  CREATE TRIGGER AggiornamentoCliente
  BEFORE UPDATE ON Cliente
  FOR EACH ROW
  BEGIN 
  
  IF new.TutorAttuale NOT IN (SELECT CodFiscale FROM Personale WHERE Ruolo='Tutor') THEN 
   SIGNAL SQLSTATE '45000'
   SET MESSAGE_TEXT='Il dipendente che si sta inserendo non è un Tutor';
  END IF;
  
  END $$
  DELIMITER ;
  
  
  DROP TRIGGER IF EXISTS InserimentoVisita;
  DELIMITER $$
  CREATE TRIGGER InserimentoVisita
  BEFORE INSERT ON Visita
  FOR EACH ROW
  BEGIN 
  
  IF new.Medico NOT IN (SELECT CodFiscale FROM Personale WHERE Ruolo='Medico') THEN 
   SIGNAL SQLSTATE '45000'
   SET MESSAGE_TEXT='Il dipendente che si sta inserendo non è un medico';
  END IF;

  END $$
  DELIMITER ;
  
  
   DROP TRIGGER IF EXISTS InserimentoMisurazione;
  DELIMITER $$
  CREATE TRIGGER InserimentoMisurazione
  BEFORE INSERT ON Misurazione
  FOR EACH ROW
  BEGIN 
  
  IF new.Medico NOT IN (SELECT CodFiscale FROM Personale WHERE Ruolo='Medico') THEN 
   SIGNAL SQLSTATE '45000'
   SET MESSAGE_TEXT='Il dipendente che si sta inserendo non è un medico';
  END IF;

  END $$
  DELIMITER ;
  
 
  DROP TRIGGER IF EXISTS AggiornamentoVisita;
  DELIMITER $$
  CREATE TRIGGER AggiornamentoVisita
  BEFORE UPDATE ON Visita
  FOR EACH ROW
  BEGIN 
  
  IF new.Medico NOT IN (SELECT CodFiscale FROM Personale WHERE Ruolo='Medico') THEN 
   SIGNAL SQLSTATE '45000'
   SET MESSAGE_TEXT='Il dipendente che si sta inserendo non è un medico';
  END IF;

  END $$
  DELIMITER ;
  
  
   DROP TRIGGER IF EXISTS AggiornamentoMisurazione;
  DELIMITER $$
  CREATE TRIGGER AggiornamentoMisurazione
  BEFORE UPDATE ON Misurazione
  FOR EACH ROW
  BEGIN 
  
  IF new.Medico NOT IN (SELECT CodFiscale FROM Personale WHERE Ruolo='Medico') THEN 
   SIGNAL SQLSTATE '45000'
   SET MESSAGE_TEXT='Il dipendente che si sta inserendo non è un medico';
  END IF;

  END $$
  DELIMITER ;
  
  
 */ 
  
  DROP TRIGGER IF EXISTS ControllaAccessiCentro;
  DELIMITER $$
  CREATE TRIGGER ControllaAccessiCentro
  BEFORE INSERT ON Log_Accesso
  FOR EACH ROW
  BEGIN
  
  DECLARE VolteSettimana INT DEFAULT 0;
  DECLARE NumeroMassimo INT DEFAULT 0;
  DECLARE Tip CHAR(15) DEFAULT '';
  DECLARE Contr CHAR(10) DEFAULT '';
  
  
  SELECT C.CodContratto,C.Tipologia INTO Contr,Tip
  FROM  Contratto C
  WHERE Cliente=new.Cliente
  AND   C.DataSottoscrizione=(SELECT MAX(CC.DataSottoscrizione) FROM Contratto CC WHERE CC.Cliente=new.Cliente)
  AND NEW.DataAccesso BETWEEN C.DataSottoscrizione AND (C.DataSottoscrizione + INTERVAL C.DuratainMesi MONTH);
  
  
  IF (new.Centro NOT IN (SELECT AC.Centro FROM AutorizzazioneCentro AC WHERE AC.Contratto=Contr)) AND 
     (new.Centro NOT IN (SELECT AP.Centro FROM AutorizzazionePersonalizzata AP WHERE Contr=AP.Contratto))THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT='Il cliente non ha il permesso di entrare nel centro!';
  END IF;
  
  IF (NEW.Cliente NOT IN (SELECT Cliente FROM Visita WHERE DataVisita<=NEW.DataAccesso)) THEN
  
      SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT='Il cliente non ha ancora effettuata alcuna visita';
  END IF;
  
  
   
   IF EXISTS (SELECT * 
              FROM AccessoCentro
              WHERE Cliente=NEW.Cliente 
              AND DataAccesso=NEW.DataAccesso
			  AND NEW.OrarioAccesso BETWEEN OrarioAccesso AND OrarioUscita) THEN
     SIGNAL SQLSTATE '45000'
     SET MESSAGE_TEXT= 'Errore di sistema, inserimento accesso compreso in accesso precedente!';
   END IF;
   
   IF (Tip IN (SELECT NomeAbbonamento FROM AbbonamentoStandard)) THEN
   BEGIN
   
   SELECT MaxNumeroIngressiSettimanali INTO NumeroMassimo
   FROM AbbonamentoStandard
   WHERE NomeAbbonamento=Tip;
   END;
   
  ELSE
  BEGIN
  
   SELECT MaxNumeroIngressiSettimanali INTO NumeroMassimo
   FROM AutorizzazionePersonalizzata AP
   WHERE AP.Contratto=Contr
     AND AP.Centro=new.Centro;
  END;
  END IF;
  
  
  SELECT COUNT(*) INTO VolteSettimana
  FROM AccessoCentro AC INNER JOIN Contratto C
  ON AC.Cliente = C.Cliente
  WHERE C.CodContratto=Contr
  AND WEEK(DataAccesso,1)=WEEK(NEW.DataAccesso,1)
  AND YEAR(DataAccesso)=YEAR(NEW.DataAccesso);
  
  IF (VolteSettimana>=NumeroMassimo) THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT='Numero accessi settimanali superati!';
  END IF;
  
  END $$
  DELIMITER ;
  
  
  
    DROP TRIGGER IF EXISTS ControllaAccessiSala;
  DELIMITER $$
  CREATE TRIGGER ControllaAccessiSala
  BEFORE INSERT ON Log_Sala
  FOR EACH ROW 
  BEGIN 
  
    DECLARE Abbonamento_Sala INT DEFAULT 0;
    DECLARE PrioritaSala INT DEFAULT 0;
    DECLARE PrioritaCliente INT DEFAULT 0;
    DECLARE ContaAccessiPiscinaMese INT DEFAULT 0;
    DECLARE ContrattoCliente VARCHAR(50) DEFAULT '';
    DECLARE Tipologia_Contratto VARCHAR(50) DEFAULT '';
    DECLARE Accesso INT DEFAULT 0;
    DECLARE Gia_Inserito INT DEFAULT 0;
	DECLARE Gia_Inserito_Passato INT DEFAULT 0;
    DECLARE Iscritto INT DEFAULT 0;
    DECLARE Corso_Sala VARCHAR(20) DEFAULT '';
    DECLARE Nome_Corso VARCHAR(20) DEFAULT '';
    DECLARE Abilitato BOOL DEFAULT 0;
    DECLARE AccessiPiscine INT DEFAULT 0;

    
    SELECT C.CodContratto,C.Tipologia INTO ContrattoCliente,Tipologia_Contratto
    FROM Contratto C
    WHERE C.Cliente=NEW.Cliente
     AND C.DataSottoscrizione=(SELECT MAX(CC.DataSottoscrizione)
							   FROM Contratto CC
							   WHERE CC.Cliente=NEW.Cliente)
     AND NEW.DataAccesso BETWEEN C.DataSottoscrizione AND (C.DataSottoscrizione + INTERVAL  
                        C.DuratainMesi MONTH);
    
    IF (ContrattoCliente IS NULL OR ContrattoCliente='') THEN 
         
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT='Il cliente non ha un contratto attivo';
     
   END IF;

    SELECT AbbonamentoMinimo INTO PrioritaSala
	FROM Sala
	WHERE CodSala=NEW.Sala;
    
      IF (Tipologia_Contratto='Personalizzato') THEN 
       BEGIN
       
         
		SELECT AccessoPiscine, NumeroMaxIngressoPiscineMese,Priorita 
             INTO Abilitato,AccessiPiscine,PrioritaCliente
		FROM AutorizzazionePersonalizzata
		WHERE Contratto=ContrattoCliente;
        
	   END;
	
      ELSE 
       
        SELECT Priorita,AccessoPiscine,NumeroMaxIngressoPiscineMese INTO PrioritaCliente,Abilitato,AccessiPiscine
        FROM AbbonamentoStandard
        WHERE NomeAbbonamento=Tipologia_Contratto;
	
	  END IF;
    
    
    IF  ((SELECT TipoSala FROM Sala WHERE CodSala=NEW.Sala)='Piscina' AND Abilitato=0) THEN
       SIGNAL SQLSTATE '45000'
       SET MESSAGE_TEXT='Il cliente non è abilitato ad entrare nella sala(piscina)';
	ELSE 
       
       SELECT COUNT(*) INTO ContaAccessiPiscinaMese
       FROM AccessoSala A INNER JOIN Sala S
        ON S.CodSala=A.Sala
	   WHERE YEAR(A.DataAccesso)=YEAR(NEW.DataAccesso)
        AND MONTH(A.DataAccesso)=MONTH(NEW.DataAccesso)
        AND A.Cliente=NEW.Cliente
        AND S.TipoSala='Piscina';
        
        IF (ContaAccessiPiscinaMese>AccessiPiscine) THEN
          SIGNAL SQLSTATE '45000'
          SET MESSAGE_TEXT='Limite accesso piscine raggunto!';
		END IF;
    
      
    
      IF (PrioritaSala>PrioritaCliente) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT='Cliente non abilitato ad entrare nella sala';
	  END IF;

      
       
       SET @Errore=CONCAT('Errore di sistema, il cliente ',NEW.Cliente,' non risulta nel centro in data',' ',NEW.DataAccesso);
       
	  IF NOT EXISTS (SELECT * 
					 FROM Log_Accesso
					 WHERE DataAccesso=NEW.DataAccesso) THEN
		 SIGNAL SQLSTATE '45000'
		 SET MESSAGE_TEXT=@Errore;
	  ELSE
      
	   BEGIN
       
		SET @Errore=CONCAT('Errore di sistema, il cliente ',NEW.Cliente,' si trova ancora nella sala  
                              precedente!',' ',NEW.DataAccesso);
         
		IF EXISTS (SELECT * 
				   FROM Log_Sala
				   WHERE Cliente=NEW.Cliente) THEN
            
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT=@Errore;
		
        END IF;
     
        
        SELECT C.CodCorso,C.NomeDisciplina INTO Corso_Sala,Nome_Corso
        FROM Corso C INNER JOIN CalendarioLezioni CL
        ON C.CodCorso=CL.CodCorso
        WHERE CL.GiornoSettimana=DAYNAME(NEW.DataAccesso)
        AND NEW.DataAccesso BETWEEN C.InizioCorso AND C.FineCorso
        AND NEW.OrarioAccesso BETWEEN CL.OrarioInizio AND CL.OrarioFine;  
         
         IF (Nome_Corso IS NOT NULL AND Nome_Corso<>'') THEN
           BEGIN
          
                   SET @Errore=CONCAT('Utente',' ',NEW.Cliente,' non iscritto al corso di',' ',Nome_Corso);
          
		   IF NOT EXISTS (SELECT * 
						  FROM IscrizioneCorsi
						  WHERE Corso=Corso_Sala
						  AND Cliente=NEW.Cliente) THEN
             SIGNAL SQLSTATE '45000'
             SET MESSAGE_TEXT=@Errore;
           END IF;
           END;
		  END IF;
		END; 
	  END IF;
	 END IF;
END $$
DELIMITER ;
  
  
  
  
  
  
  
  
     
   
      

     
     
 /*  
   
DROP TRIGGER IF EXISTS AggiornaResp;
DELIMITER $$
CREATE TRIGGER AggiornaResp
BEFORE UPDATE ON Personale
FOR EACH ROW 
BEGIN 
 IF (NEW.Responsabile<>OLD.CodFiscale) THEN
  BEGIN 
  
   IF (NEW.Responsabile IS NOT NULL) THEN
	 BEGIN
       SELECT Ruolo INTO @RuoloResp
       FROM Responsabile
       WHERE CodFiscale=new.Responsabile;


      IF (OLD.CodFiscale IN (SELECT CodFiscale FROM Medico)) THEN             /* CONTROLLO RUOLI */
 /*      BEGIN 
       
        SET @Ruolo='Medico';
        
          IF (@Ruolo=@RuoloResp) THEN 
            UPDATE Medico
			SET Responsabile=NEW.Responsabile
            WHERE CodFiscale=OLD.CodFiscale;
		  ELSE 
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT='Ruolo non coincidente';
		  END IF;
          
        END ;
	  ELSE IF (OLD.CodFiscale IN (SELECT CodFiscale FROM Istruttore)) THEN 
			BEGIN
            
             SET @Ruolo='Istruttore';
             
             IF (@Ruolo=@RuoloResp) THEN 
              UPDATE Istruttore
			  SET Responsabile=NEW.Responsabile
              WHERE CodFiscale=OLD.CodFiscale;
		     ELSE 
              SIGNAL SQLSTATE '45000'
              SET MESSAGE_TEXT='Ruolo non coincidente';
		     END IF;
             
		     END ;
			ELSE IF (OLD.CodFiscale IN (SELECT CodFiscale FROM Segreteria)) THEN
                   BEGIN   
				     
                     SET @Ruolo='Segreteria';
                
                     IF (@Ruolo=@RuoloResp) THEN 
                      UPDATE Segreteria
			          SET Responsabile=NEW.Responsabile
                      WHERE CodFiscale=OLD.CodFiscale;
		             ELSE 
                      SIGNAL SQLSTATE '45000'
                      SET MESSAGE_TEXT='Ruolo non coincidente';
		             END IF;
                   END;
	              END IF;
		    END IF;
	   END IF;
	 END;
  END IF;
  END;
ELSE 
 SIGNAL SQLSTATE '45000'
 SET MESSAGE_TEXT='Responsabile uguale al dipendente che stiamo modificando!';
END IF;

END $$
*/
DELIMITER ;
     
    
	
		
				
 DROP TRIGGER IF EXISTS CheckRuoloRespIN;
 DELIMITER $$
 CREATE TRIGGER CheckRuoloRespIN
 BEFORE INSERT ON Responsabilita
 FOR EACH ROW
 BEGIN
 
 IF (NEW.Dipendente IN (SELECT CodFiscale FROM Istruttore)) THEN 
      
      SET @Ruolo='Istruttore';
      
 ELSE IF (NEW.Dipendente IN (SELECT CodFiscale FROM Medico)) THEN 
           
           SET @Ruolo='Medico';
           
      ELSE IF (NEW.Dipendente IN (SELECT CodFiscale FROM Segreteria )) THEN 
            
            SET @Ruolo='Segreteria';
      
		   ELSE 
			 SIGNAL SQLSTATE '45000'
             SET MESSAGE_TEXT='Persona non esistente';
		   END IF;
	   END IF;
  END IF;
  
  
  IF (NEW.Responsabile IN (SELECT CodFiscale FROM Istruttore)) THEN 
      
      SET @RuoloResp='Istruttore';
      
 ELSE IF (NEW.Responsabile IN (SELECT CodFiscale FROM Medico)) THEN 
           
           SET @RuoloResp='Medico';
           
      ELSE IF (NEW.Responsabile IN (SELECT CodFiscale FROM Segreteria )) THEN 
            
            SET @RuoloResp='Segreteria';
      
		   ELSE 
			 SIGNAL SQLSTATE '45000'
             SET MESSAGE_TEXT='Persona non esistente';
		   END IF;
	   END IF;
  END IF;
  
  IF @RuoloResp<>@Ruolo THEN 
    
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT='Il ruolo del dipendente è diverso da quello del responsabile';
  END IF;
END $$
DELIMITER ;



DROP TRIGGER IF EXISTS CheckRuoloRespUP;
 DELIMITER $$
 CREATE TRIGGER CheckRuoloRespUP
 BEFORE UPDATE ON Responsabilita
 FOR EACH ROW
 BEGIN
 
 IF (NEW.Dipendente IN (SELECT CodFiscale FROM Istruttore)) THEN 
      
      SET @Ruolo='Istruttore';
      
 ELSE IF (NEW.Dipendente IN (SELECT CodFiscale FROM Medico)) THEN 
           
           SET @Ruolo='Medico';
           
      ELSE IF (NEW.Dipendente IN (SELECT CodFiscale FROM Segreteria )) THEN 
            
            SET @Ruolo='Segreteria';
      
		   ELSE 
			 SIGNAL SQLSTATE '45000'
             SET MESSAGE_TEXT='Persona non esistente';
		   END IF;
	   END IF;
  END IF;
  
  
  IF (NEW.Responsabile IN (SELECT CodFiscale FROM Istruttore)) THEN 
      
      SET @RuoloResp='Istruttore';
      
 ELSE IF (NEW.Responsabile IN (SELECT CodFiscale FROM Medico)) THEN 
           
           SET @RuoloResp='Medico';
           
      ELSE IF (NEW.Responsabile IN (SELECT CodFiscale FROM Segreteria )) THEN 
            
            SET @RuoloResp='Segreteria';
      
		   ELSE 
			 SIGNAL SQLSTATE '45000'
             SET MESSAGE_TEXT='Persona non esistente';
		   END IF;
	   END IF;
  END IF;
  
  IF @RuoloResp<>@Ruolo THEN 
    
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT='Il ruolo del dipendente è diverso da quello del responsabile';
  END IF;
END $$
DELIMITER ;



 
 
 DROP TRIGGER IF EXISTS DecrementaPartecipanti;
DELIMITER $$
CREATE TRIGGER DecrementaPartecipanti
AFTER DELETE ON AderisciSfida
FOR EACH ROW 
BEGIN 

 UPDATE Sfida
 SET NumeroPartecipanti= NumeroPartecipanti -1
 WHERE CodSfida=OLD.CodSfida;
 
END $$
DELIMITER ;




DROP TRIGGER IF EXISTS ControllaPubSfida;

DELIMITER $$
CREATE TRIGGER ControllaPubSfida
BEFORE INSERT ON PostRisposta
FOR EACH ROW
BEGIN 
    declare _areaforum char(100) DEFAULT '';
    select areaforum into _areaforum
    from postprincipale
    where codpost=new.postprincipale;
IF _areaforum='Sfide' THEN
BEGIN
 IF ((NEW.Username NOT IN (SELECT A.utente
                          FROM aderiscisfida A natural join sfida S
                          WHERE S.Codpost=new.postprincipale))
	AND
	(NEW.Username NOT IN (SELECT S2.utenteproponente
                          FROM sfida S2
                          WHERE S2.Codpost=new.postprincipale))) THEN
	 SIGNAL SQLSTATE '45000'
     SET MESSAGE_TEXT='Pubblicazione consentita ai soli partecipanti';

END IF;
end ;
END IF;
END $$
DELIMITER ;








/*
DROP TRIGGER IF EXISTS ControllaTipoSala;
DELIMITER $$
CREATE TRIGGER 	ControllaTipoSala
BEFORE INSERT ON Corso
FOR EACH ROW 
BEGIN 
  
  DECLARE _TipoSala VARCHAR(80) DEFAULT '';

  
  SELECT TipoSala INTO _TipoSala
  FROM Sala
  WHERE CodSala=NEW.Sala;
  
  IF NOT EXIST( SELECT *
                FROM TipologiaCorso_Sala
                WHERE Disciplina=NEW.Disciplina
                 AND TipoSala=_TipoSala) THEN
	 SIGNAL SQLSTATE '45000'
     SET MESSAGE_TEXT='Sala e Disciplina non combaciano';
  END IF;

 END IF ;
 
 END $$
 DELIMITER ;
 
 */


    

 DROP TRIGGER IF EXISTS ControllaProfiloI;
  DELIMITER $$
  CREATE TRIGGER ControllaProfiloI
  BEFORE INSERT ON ProfiloSocial
  FOR EACH ROW
  BEGIN 
   
   IF (NEW.Proprietario NOT IN (SELECT CodFiscale FROM Cliente) )AND 
      (NEW.Proprietario NOT IN (SELECT CodFiscale FROM Personale)) THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT ='Proprietario non valido';
   END IF;
   
   END $$
   DELIMITER ;
   
   
   
  DROP TRIGGER IF EXISTS ControllaProfiloDP;
  DELIMITER $$
  CREATE TRIGGER ControllaProfiloDP
  AFTER DELETE ON Personale
  FOR EACH ROW
  BEGIN 
   
   DELETE 
   FROM ProfiloSocial
   WHERE Proprietario=OLD.CodFiscale;
   
   END $$
   DELIMITER ;
   
   DROP TRIGGER IF EXISTS ControllaProfiloDC;
  DELIMITER $$
  CREATE TRIGGER ControllaProfiloDC
  AFTER DELETE ON Cliente
  FOR EACH ROW
  BEGIN 
   
   DELETE 
   FROM ProfiloSocial
   WHERE Proprietario=OLD.CodFiscale;
   
   END $$
   DELIMITER ;





           
   
   
   

  
DROP TRIGGER IF EXISTS AggiornaSaldoCliente;
DELIMITER $$
CREATE TRIGGER AggiornaSaldoCliente 
AFTER INSERT ON saldiareeallestibilidapagare
FOR EACH ROW 
BEGIN
  UPDATE Saldoareeallestibilicliente
  SET Saldomese=Saldomese + NEW.Saldo,SaldoTotale=SaldoTotale+NEW.Saldo
  WHERE Cliente=NEW.Cliente;
END $$
DELIMITER ;





  
  
  

  

  /*
DROP TRIGGER IF EXISTS ControllaChiaveAccessoSala;
DELIMITER $$
CREATE TRIGGER ControllaChiaveAccessoSala
BEFORE INSERT ON AccessoSala
FOR EACH ROW
BEGIN  

   IF (NEW.Sala NOT IN (SELECT CodSala FROM Sala) AND NEW.Sala NOT IN (SELECT CodPiscina FROM Piscina)) THEN
     SIGNAL SQLSTATE '45000'
     SET MESSAGE_TEXT='Errore, sala non esistente';
   END IF;
END $$
DELIMITER ;
*/

  
  
  
DROP TRIGGER IF EXISTS AccessoSalaMedica;
DELIMITER $$
CREATE TRIGGER AccessoSalaMedica
BEFORE INSERT ON Log_SalaMedica
FOR EACH ROW
BEGIN 
  
  DECLARE Permesso INT DEFAULT 0;
  DECLARE ConflittoAccessoCentro INT DEFAULT 0;
  
  SELECT COUNT(*) INTO Permesso
  FROM Contratto C INNER JOIN AutorizzazioneCentro AC
   ON C.CodContratto=AC.Contratto
  WHERE AC.Centro=NEW.Centro
   AND NEW.DataAccesso BETWEEN C.DataSottoscrizione AND (C.DataSottoscrizione + INTERVAL C.DuratainMesi MONTH)
   AND C.Cliente=NEW.Cliente;
  
  IF Permesso=0 THEN
   SIGNAL SQLSTATE '45000'
   SET MESSAGE_TEXT='Il cliente non è autorizzato ad entrare nella sala medica';
  END IF;

 IF (NEW.Cliente IN (SELECT Cliente FROM Log_Accesso)) THEN 
   SIGNAL SQLSTATE '45000'
   SET MESSAGE_TEXT='Errore di sistema, il cliente si trova già nel centro!!';
 END IF;
 
 END $$
 DELIMITER ;


  DROP TRIGGER IF EXISTS IscriviaiCorsi;
DELIMITER $$
CREATE TRIGGER IscriviaiCorsi
BEFORE INSERT ON IscrizioneCorsi
FOR EACH ROW
BEGIN 
   
   DECLARE Tipologia_Contratto VARCHAR(20) DEFAULT '';
   DECLARE Frequentazione BOOL DEFAULT 0;
   DECLARE Centro_Corso VARCHAR(20) DEFAULT '';
   DECLARE Contratto_Cliente VARCHAR(50) DEFAULT '';
   DECLARE MassimoIscritti INT DEFAULT 0;
   DECLARE SalaCorso VARCHAR(20) DEFAULT '';
   DECLARE Tipo_Sala VARCHAR(20) DEFAULT '';
   DECLARE PrioritaCliente INT DEFAULT 0;
   DECLARE Piscina BOOL DEFAULT 0;
  
  SELECT NumeroMaxPartecipanti INTO MassimoIscritti
  FROM Corso
  WHERE CodCorso=NEW.Corso;
  
  IF ((SELECT COUNT(*) FROM IscrizioneCorsi WHERE Corso=NEW.Corso)>=MassimoIscritti) THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT='Massimo numero di iscritti raggiunto';
  END IF;

   
   
   SELECT Tipologia INTO Tipologia_Contratto
   FROM Contratto
   WHERE Cliente=NEW.Cliente;
   
   IF (Tipologia_Contratto='Personalizzato') THEN
    
    BEGIN
    
     SELECT S.Centro,S.CodSala,S.TipoSala INTO Centro_Corso, SalaCorso,Tipo_Sala
     FROM Corso C INNER JOIN Sala S 
      ON C.Sala=S.CodSala
	 WHERE C.CodCorso=NEW.Corso;
     
     SELECT C.CodContratto INTO Contratto_Cliente
     FROM Contratto C
     WHERE C.Cliente=NEW.Cliente
      AND C.DataSottoscrizione=(SELECT MAX(C2.DataSottoscrizione)
							    FROM Contratto C2
                                WHERE C2.Cliente=NEW.Cliente);
     
     
     
     SELECT PossibilitaFrequentazioneCorsi,Priorita,AccessoPiscine INTO Frequentazione, PrioritaCliente, Piscina
     FROM AutorizzazionePersonalizzata
     WHERE Centro=Centro_Corso
      AND Contratto=Contratto_Cliente;
      
	 IF  ((Tipo_Sala='Piscina' AND Piscina=0) AND (PrioritaCliente<(SELECT AbbonamentoMinimo FROM Sala WHERE CodSala=SalaCorso))) THEN
        
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT='Il cliente non ha la possibilità di entrare nella sala!';
	  END IF;
      
     END;
     
    END IF;
     
   
   IF (Tipologia_Contratto='Silver') OR 
      ( Tipologia_Contratto='Personalizzato' AND Frequentazione=0) THEN
      
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT ='Il Cliente non ha il permesso di seguire corsi!';
   
   END IF;
END $$
DELIMITER ;


DROP TRIGGER IF EXISTS ControlloInserimento_Visita;
DELIMITER $$
CREATE TRIGGER ControlloInserimento_Visita
BEFORE INSERT ON Visita
FOR EACH ROW
BEGIN

 DECLARE CentroCliente VARCHAR(50) DEFAULT '';

SELECT Centro INTO CentroCliente
FROM AccessoSala_Medica
WHERE DataAccesso=NEW.DataVisita
 AND NEW.OraVisita BETWEEN OrarioAccesso AND OrarioUscita
 AND Cliente=NEW.Cliente;
 
 IF (CentroCliente IS NULL OR CentroCliente='') THEN
  
  SELECT Centro INTO CentroCliente
  FROM Log_SalaMedica
  WHERE DataAccesso=NEW.DataVisita
  AND Cliente=NEW.Cliente
  AND NEW.OraVisita>=OrarioAccesso;
  
 END IF;
 
 
 IF (CentroCliente IS NULL OR CentroCliente='') THEN
   BEGIN 
     SET @errore=CONCAT('Il cliente ',NEW.Cliente,' non ha effettuato accessi in data ',NEW.DataVisita);
     SIGNAL SQLSTATE '45000'
     SET MESSAGE_TEXT=@errore;
   END;
END IF;
   
   
   
IF (NOT EXISTS (SELECT * FROM Turnazione 
                WHERE Dipendente=NEW.Medico 
                 AND DAYNAME(NEW.DataVisita)=GiornoSettimana
                 AND NEW.OraVisita BETWEEN InizioTurno AND FineTurno
                 AND Centro=CentroCliente)) THEN
   
   SIGNAL SQLSTATE '45000'
   SET MESSAGE_TEXT='Il tutor non lavora nel centro del cliente';
END IF;
END $$
DELIMITER ;
       
   
  
  
  
  /*
DROP TRIGGER IF EXISTS CalcoloPerformance;
DELIMITER $$
CREATE TRIGGER CalcoloPerformance 
AFTER INSERT ON EsercizioSvolto
FOR EACH ROW
BEGIN
  declare _tipoesercizio char(15) default ' ';
  declare _schedaallenamento char(20) default ' ';
  declare _giornoscheda INT default 0;
  declare _esercizio char(10) default ' ';
  
  set _schedaallenamento=NEW.schedaallenamento;
  set _giornoscheda=NEW.giornoscheda;
  set _esercizio=NEW.esercizio;
  
  IF NOT EXISTS (select *
                 from esercizioscheda
				 where scheda=_schedaallenamento
                       AND
                       giorno=_giornoscheda
                       AND
                       esercizio=_esercizio) THEN
		Insert into LogPerfomance
        VALUES (NEW.istanteinizio,NEW.cliente,"Esercizio non compatibile alla scheda",NULL,NULL,NULL);
  END IF;
  
  set _tipoesercizio=(select tipoesercizio
                      from esercizio
                      where codesercizio=_esercizio);
		
                      
    IF _tipoesercizio='aerobico' THEN
  
    CALL AnalisiPerformanceEsercizioAerobico(NEW.cliente,NEW.esercizio,NEW.istanteinizio,NEW.schedaallenamento,
    NEW.Durata,NEW.TempodiRecupero,NEW.GiornoScheda);
    
    ELSE
    
    CALL AnalisiPerformanceEsercizioAnaerobico(NEW.cliente,NEW.esercizio,NEW.istanteinizio,NEW.schedaallenamento,
    NEW.Ripetizioni,NEW.Serie,NEW.TempodiRecupero,NEW.GiornoScheda);
    
    END IF;
    

END $$
DELIMITER ;
 */

  
DROP TRIGGER IF EXISTS AggiornaVittorie;
DELIMITER $$
CREATE TRIGGER AggiornaVittorie
AFTER INSERT ON Vincitore_Sfida
FOR EACH ROW 
BEGIN
 
 UPDATE ProfiloSocial
 SET SfideVinte=SfideVinte+1
 WHERE Username=NEW.Vincitore;
 
END $$
DELIMITER ;

DROP TRIGGER IF EXISTS AggiornaVittorie;
DELIMITER $$
CREATE TRIGGER AggiornaVittorie
AFTER DELETE ON Vincitore_Sfida
FOR EACH ROW 
BEGIN
 
 UPDATE ProfiloSocial
 SET SfideVinte=SfideVinte-1
 WHERE Username=OLD.Vincitore;
 
END $$
DELIMITER ;