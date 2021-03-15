CREATE TABLE IF NOT EXISTS Documento(
 CodDocumento char(10) not null,
 Prefettura char(80) not null,
 PRIMARY KEY (CodDocumento)
 ) ENGINE=InnoDB DEFAULT CHARSET=latin1;
 
 CREATE TABLE IF NOT EXISTS Personale (
 CodFiscale char(16) not null,
 Nome char(80) not null,
 Cognome char(80) not null,
 DataNascita date not null,
 Sesso char(1) not null,
 Residenza char(80) not null,
 Indirizzo char(80) not null,
 DocumentoRiconoscimento char(10),
 Telefono char(12) not null,
 Responsabile char(16),
 PRIMARY KEY(CodFiscale),
 CONSTRAINT RiconoscimentoP
 FOREIGN KEY (DocumentoRiconoscimento)
 REFERENCES Documento(CodDocumento)
 ON DELETE SET NULL
 ON UPDATE CASCADE
 ) ENGINE=InnoDB DEFAULT CHARSET=latin1;
 
 
 CREATE TABLE IF NOT EXISTS Medico (
 CodFiscale char(16) not null,
 Nome char(80) not null,
 Cognome char(80) not null,
 DataNascita date not null,
 Sesso char(1) not null,
 Residenza char(80) not null,
 Indirizzo char(80) not null,
 DocumentoRiconoscimento char(10),
 Telefono char(12) not null,
 Responsabile char(50),
 PRIMARY KEY(CodFiscale),
 CONSTRAINT RiconoscimentoMed
 FOREIGN KEY (DocumentoRiconoscimento)
 REFERENCES Documento(CodDocumento)
 ON DELETE SET NULL
 ON UPDATE CASCADE,
 CONSTRAINT Personale_Medico
 FOREIGN KEY (CodFiscale)
 REFERENCES Personale(CodFiscale)
 ON DELETE CASCADE
 ON UPDATE CASCADE
 ) ENGINE=InnoDB DEFAULT CHARSET=latin1;
 
 
 CREATE TABLE IF NOT EXISTS Istruttore (
 CodFiscale char(16) not null,
 Nome char(80) not null,
 Cognome char(80) not null,
 DataNascita date not null,
 Sesso char(1) not null,
 Residenza char(80) not null,
 Indirizzo char(80) not null,
 DocumentoRiconoscimento char(10),
 Telefono char(12) not null,
 Responsabile char(50),
 PRIMARY KEY(CodFiscale),
 CONSTRAINT RiconoscimentoIstrut
 FOREIGN KEY (DocumentoRiconoscimento)
 REFERENCES Documento(CodDocumento)
 ON DELETE SET NULL
 ON UPDATE CASCADE,
 CONSTRAINT Personale_Istruttore
 FOREIGN KEY (CodFiscale)
 REFERENCES Personale(CodFiscale)
 ON DELETE CASCADE
 ON UPDATE CASCADE
 ) ENGINE=InnoDB DEFAULT CHARSET=latin1;
 
 
 CREATE TABLE IF NOT EXISTS Segreteria (
 CodFiscale char(16) not null,
 Nome char(80) not null,
 Cognome char(80) not null,
 DataNascita date not null,
 Sesso char(1) not null,
 Residenza char(80) not null,
 Indirizzo char(80) not null,
 DocumentoRiconoscimento char(10),
 Telefono char(12) not null,
 Responsabile char(50),
 PRIMARY KEY(CodFiscale),
 CONSTRAINT RiconoscimentoSegr
 FOREIGN KEY (DocumentoRiconoscimento)
 REFERENCES Documento(CodDocumento)
 ON DELETE SET NULL
 ON UPDATE CASCADE,
 CONSTRAINT Personale_Segreteria
 FOREIGN KEY (CodFiscale)
 REFERENCES Personale(CodFiscale)
 ON DELETE CASCADE
 ON UPDATE CASCADE
 ) ENGINE=InnoDB DEFAULT CHARSET=latin1;
 
 
 
 CREATE TABLE IF NOT EXISTS Responsabile (
 Responsabile char(16) not null,
 Ruolo char(30) not null DEFAULT '',
 PRIMARY KEY(Responsabile),
 CONSTRAINT ResponsabilePersonale
 FOREIGN KEY(Responsabile)
 REFERENCES Personale(CodFiscale)
 ON DELETE CASCADE
 ON UPDATE CASCADE
 )ENGINE=InnoDB DEFAULT CHARSET=latin1;
 
 CREATE TABLE IF NOT EXISTS Dirigente(
 CodFiscale char(16) not null,
 Nome char(80) not null,
 Cognome char(80) not null,
 DataNascita date not null,
 Sesso char(1) not null,
 Residenza char(80) not null,
 Indirizzo char(80) not null,
 CodiceDocumentoRiconoscimento char(10),
 Telefono char(12) not null,
 PRIMARY KEY(CodFiscale),
 CONSTRAINT RiconoscimentoDirigente
 FOREIGN KEY (CodiceDocumentoRiconoscimento)
 REFERENCES Documento(CodDocumento)
 ON DELETE SET NULL
 ON UPDATE CASCADE
 ) ENGINE=InnoDB DEFAULT CHARSET=latin1;
 
ALTER TABLE Personale
 ADD CONSTRAINT Responsabilita
 FOREIGN KEY (Responsabile)
 REFERENCES Responsabile(Responsabile)
 ON DELETE SET NULL
 ON UPDATE CASCADE;
 
 ALTER TABLE Medico
 ADD CONSTRAINT ResponsabilitaMed
 FOREIGN KEY (Responsabile)
 REFERENCES Responsabile(Responsabile)
 ON DELETE SET NULL
 ON UPDATE CASCADE;
 
 ALTER TABLE Istruttore
 ADD CONSTRAINT ResponsabilitaIstrutt
 FOREIGN KEY (Responsabile)
 REFERENCES Responsabile(Responsabile)
 ON DELETE SET NULL
 ON UPDATE CASCADE;
 
 ALTER TABLE Segreteria
 ADD CONSTRAINT ResponsabilitaSegr
 FOREIGN KEY (Responsabile)
 REFERENCES Responsabile(Responsabile)
 ON DELETE SET NULL
 ON UPDATE CASCADE;
 
CREATE TABLE IF NOT EXISTS TipologiaCorso_Sala (
TipoSala CHAR(80) not null,
Disciplina CHAR(80) not null,
PRIMARY KEY(TipoSala,Disciplina)
)ENGINE=InnoDB DEFAULT CHARSET=latin1;
 
CREATE TABLE IF NOT EXISTS Centro (
CodCentro char(10) not null,
Citta char(80) not null,
Indirizzo char(80) not null,
Telefono char(12) not null,
Dimensionemetriquadri int,
Maxclientiospitabili int,
Dirigente char(16) not null,
GuadagnoIntegratori double DEFAULT 0 not null,
PRIMARY KEY(CodCentro)
)ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS Sala(
CodSala char(10) not null,
NomeSala char(30) not null,
TipoSala char(80) not null,
AbbonamentoMinimo int not null,
Responsabile char(16) not null,
Centro char(20) not null,
Interno bool not null,
TariffaAccessoSingolo double not null,
PRIMARY KEY (CodSala),
CONSTRAINT ResponsabilitaSala
FOREIGN KEY (Responsabile)
REFERENCES Responsabile(Responsabile)
ON DELETE NO ACTION
ON UPDATE CASCADE,
CONSTRAINT CentroAppartenenza
FOREIGN KEY (Centro)
REFERENCES Centro(CodCentro)
ON DELETE CASCADE
ON UPDATE NO ACTION,
CONSTRAINT Tipologia_Sala
FOREIGN KEY (TipoSala)
REFERENCES TipologiaCorso_Sala(TipoSala)
ON DELETE NO ACTION
ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS Cliente(
CodFiscale char(16) not null,
Nome char(80) not null,
Cognome char(80) not null,
DataNascita date not null,
Sesso char(1) not null,
Residenza char(80) not null,
Indirizzo char(80) not null,
Telefono char(12) not null,
CodiceDocumentoRiconoscimento char(10) not null,
TutorAttuale char(16),
Abbonato bool DEFAULT false not null,
PRIMARY KEY (CodFiscale),
CONSTRAINT Tutoraggio
FOREIGN KEY (TutorAttuale)
REFERENCES  Istruttore(CodFiscale)
ON DELETE SET NULL
ON UPDATE NO ACTION,
CONSTRAINT RiconoscimentoC
FOREIGN KEY (CodiceDocumentoRiconoscimento)
REFERENCES Documento(CodDocumento)
ON DELETE NO ACTION
ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=latin1;


CREATE TABLE IF NOT EXISTS CaratteristicheFisiche(
Cliente char(16) not null,
Altezza double not null,
Peso double not null,
PercentualeMassaGrassa double not null,
PercentualeMassaMagra double not null,
AcquaTotale double not null,
StatoAttuale char(30) not null,
PRIMARY KEY(Cliente),
CONSTRAINT Caratteristiche
FOREIGN KEY (Cliente)
REFERENCES Cliente(CodFiscale)
ON DELETE CASCADE
ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=latin1;



CREATE TABLE IF NOT EXISTS Contratto(
CodContratto char(10) not null,
Consulente char(16) not null,
DuratainMesi int not null,
ModPagamento char(12) not null,
Tipologia char(15) not null,
SedeSottoscrizione char(10) not null,
Scopo char(40) not null,
DataSottoscrizione date not null,
Cliente char(16) not null,
ImportoTotale int DEFAULT 0 not null,
PRIMARY KEY(CodContratto),
CONSTRAINT Consulenza
FOREIGN KEY (Consulente)
REFERENCES Segreteria(CodFiscale)
ON DELETE NO ACTION
ON UPDATE CASCADE,
CONSTRAINT Sottoscrizione
FOREIGN KEY (SedeSottoscrizione)
REFERENCES Centro(CodCentro)
ON DELETE NO ACTION
ON UPDATE CASCADE,
CONSTRAINT Clientela
FOREIGN KEY (Cliente)
REFERENCES Cliente(CodFiscale)
ON DELETE NO ACTION 
ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS AbbonamentoStandard (
NomeAbbonamento char(15) not null,
Priorita int not null,
Prezzo int not null,
MaxNumeroIngressiSettimanali int not null,
AccessoPiscine bool,
NumeroMaxIngressoPiscineMese int not null,
PossibilitaFrequentazioneCorsi bool,
PRIMARY KEY(NomeAbbonamento)
)ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS AutorizzazioneCentro(
Contratto char(10) not null,
Centro char(10) not null,
PRIMARY KEY (Contratto,Centro),
CONSTRAINT AutorizzaContratto
FOREIGN KEY (Contratto)
REFERENCES Contratto(CodContratto)
ON DELETE CASCADE
ON UPDATE CASCADE,
CONSTRAINT CentroAutorizzazione
FOREIGN KEY (Centro)
REFERENCES Centro(CodCentro)
ON DELETE CASCADE
ON UPDATE CASCADE
)Engine=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS AutorizzazionePersonalizzata(
Contratto char(10) not null,
Centro char(10) not null,
Priorita INT not null,
MaxNumeroIngressiSettimanali int not null,
AccessoPiscine bool,
NumeroMaxIngressoPiscineMese int not null,
PossibilitaFrequentazioneCorsi bool,
PRIMARY KEY (Contratto,Centro),
CONSTRAINT AutorizzaContrattoPersonalizzato
FOREIGN KEY (Contratto)
REFERENCES Contratto(CodContratto)
ON DELETE CASCADE
ON UPDATE CASCADE,
CONSTRAINT CentroAutorizzazionePersonalizzata
FOREIGN KEY (Centro)
REFERENCES Centro(CodCentro)
ON DELETE CASCADE
ON UPDATE CASCADE
)Engine=InnoDB DEFAULT CHARSET=latin1;



CREATE TABLE IF NOT EXISTS PotenziamentoMuscolare (
 Contratto char(10) not null,
 Muscolo char(50) not null,
 LivelloPotenziamento char(15) not null,
 PRIMARY KEY(Contratto,Muscolo),
 CONSTRAINT PotenziamentoCorrente
 FOREIGN KEY (Contratto)
 REFERENCES Contratto(CodContratto)
 ON DELETE CASCADE
 ON UPDATE CASCADE
 )ENGINE=InnoDB DEFAULT CHARSET=latin1;
 
 
 CREATE TABLE IF NOT EXISTS Rateizzazione (
 CodRateizzazione char(10) not null,
 Contratto char(10) not null,
 TassoInteressePercentuale double not null,
 NumeroRate int not null,
 IstitutoFinanziario char(80) not null,
 PRIMARY KEY(CodRateizzazione),
 CONSTRAINT Pagamento
 FOREIGN KEY (Contratto)
 REFERENCES Contratto(CodContratto)
 ON UPDATE CASCADE
 ON DELETE CASCADE
 )ENGINE=InnoDB DEFAULT CHARSET=latin1;
 
 
CREATE TABLE IF NOT EXISTS Rata (
CodRata char(15) not null,
Rateizzazione char(10) not null,
Importo double not null,
StatoPagamento char(25) not null,
DataScadenza date not null,
PRIMARY KEY(CodRata),
CONSTRAINT Dilazione
FOREIGN KEY (Rateizzazione)
REFERENCES Rateizzazione(CodRateizzazione)
ON UPDATE CASCADE
ON DELETE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=latin1;



CREATE TABLE IF NOT EXISTS Corso(
CodCorso char(10) not null,
NomeDisciplina char(80) not null,
LivelloInsegnamento char(20) not null,
InizioCorso date not null,
FineCorso date not null,
Sala char(10) not null,
NumeroMaxPartecipanti int not null,
NumeroIscritti int DEFAULT 0,
Istruttore char(16) not null,
PRIMARY KEY (CodCorso),
CONSTRAINT Istruzione
FOREIGN KEY (Istruttore)
REFERENCES Istruttore(CodFiscale)
ON DELETE NO ACTION
ON UPDATE CASCADE,
CONSTRAINT Sala_lezione
FOREIGN KEY (Sala)
REFERENCES Sala(CodSala)
ON DELETE NO ACTION
ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=latin1;


CREATE TABLE IF NOT EXISTS CalendarioLezioni (
CodCorso char(10) not null,
GiornoSettimana char(15) not null,
OrarioInizio time not null,
OrarioFine time not null,
PRIMARY KEY (CodCorso,GiornoSettimana,OrarioInizio),
CONSTRAINT CorsoRiferimento
FOREIGN KEY (CodCorso)
REFERENCES Corso(CodCorso)
ON DELETE CASCADE
ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS IscrizioneCorsi(
Cliente char(50) not null,
Corso char(20) not null,
PRIMARY KEY(Cliente,Corso),
CONSTRAINT IscrizioneCorso
FOREIGN KEY (Corso)
REFERENCES Corso(CodCorso)
ON DELETE CASCADE
ON UPDATE NO ACTION,
CONSTRAINT IscrizioneCliente
FOREIGN KEY (Cliente)
REFERENCES Cliente(CodFiscale)
ON DELETE CASCADE 
ON UPDATE NO ACTION
)ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS OrarioAperturaCentro (
Centro char(10) not null,
GiornoSettimana char(15) not null,
OrarioApertura time not null,
OrarioChiusura time not null,
PRIMARY KEY (Centro,GiornoSettimana),
CONSTRAINT AperturaCentro
FOREIGN KEY (Centro)
REFERENCES Centro(CodCentro)
)ENGINE=InnoDB DEFAULT CHARSET=latin1;


CREATE TABLE IF NOT EXISTS Spogliatoio(
CodSpogliatoio char(10) not null,
Capienza int not null,
Centro char(10) not null,
NumeroPostiDisponibili int not null,
PRIMARY KEY(CodSpogliatoio),
CONSTRAINT CentroContenente
FOREIGN KEY (Centro)
REFERENCES Centro(CodCentro)
ON DELETE CASCADE
ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS Armadietto(
CodArmadietto char(10) not null,
IdSpogliatoio char(10) not null,
Occupato bool not null,
PRIMARY KEY(CodArmadietto),
CONSTRAINT Locazione
FOREIGN KEY(IdSpogliatoio)
REFERENCES Spogliatoio(CodSpogliatoio)
ON DELETE CASCADE
ON UPDATE NO ACTION
)ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS Turnazione(
Dipendente char(16) not null,
Centro char(10) not null,
GiornoSettimana char(15) not null,
InizioTurno time not null,
FineTurno time not null,
PRIMARY KEY (Dipendente,Centro,InizioTurno,GiornoSettimana),
CONSTRAINT TurnoDipendente
FOREIGN KEY (Dipendente)
REFERENCES Personale(CodFiscale)
ON DELETE NO ACTION
ON UPDATE NO ACTION,
CONSTRAINT TurnoCentro
FOREIGN KEY (Centro)
REFERENCES Centro(CodCentro)
ON UPDATE NO ACTION
ON DELETE NO ACTION
)ENGINE=InnoDB DEFAULT CHARSET=latin1;


CREATE TABLE IF NOT EXISTS Dieta(
CodDieta char(10) not null,
ApportoCaloricoGiornalieto int not null,
NumeroPasti int not null,
ComposizionePasto text not null,
PRIMARY KEY(CodDieta)
)ENGINE=InnoDB DEFAULT CHARSET=latin1;


CREATE TABLE IF NOT EXISTS SchedaAlimentazione (
CodSchedaAlim Char(15) not null,
Cliente char(16) not null,
Obiettivo char(100) not null,
DataEmissione date not null,
DataInizio date not null,
DataFine date not null,
Medico char(16) not null,
Dieta char(25) not null,
IntervalloVisite_Settimane int not null,
PRIMARY KEY(CodSchedaAlim),
CONSTRAINT DietaDaSeguire
FOREIGN KEY (Dieta)
REFERENCES Dieta(CodDieta)
ON DELETE NO ACTION
ON UPDATE CASCADE,
CONSTRAINT MedicoDiRiferimento
FOREIGN KEY (Medico)
REFERENCES Medico(CodFiscale)
ON DELETE NO ACTION
ON UPDATE CASCADE,
CONSTRAINT ClienteTarget
FOREIGN KEY (Cliente)
REFERENCES Cliente(CodFiscale)
ON UPDATE CASCADE
ON DELETE NO ACTION
)ENGINE=InnoDB DEFAULT CHARSET=latin1;




CREATE TABLE IF NOT EXISTS ProfiloSocial (
Username char(60) not null,
Pass_word char(32) not null,
Proprietario char(16) not null,
NumeroStelleTotali int default 0,              /* trigger */
NumeroPostPubblicati int DEFAULT 0,            /* trigger */
SfideVinte int DEFAULT 0,                      /* trigger */               
Popolarita char(20) DEFAULT 'Sconosciuto',     /* trigger */
PRIMARY KEY (Username),
UNIQUE(Proprietario)
)ENGINE=InnoDB DEFAULT CHARSET=latin1;


CREATE TABLE IF NOT EXISTS AreaForum(
NomeArea char (50) not null,
DataUltimoPost date,
UtenteUltimoPost char(60),
UltimoPost char(30),
PRIMARY KEY (NomeArea),
CONSTRAINT UltimoPostUtente
FOREIGN KEY (UtenteUltimoPost)
REFERENCES ProfiloSocial(Username)
ON UPDATE CASCADE
ON DELETE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS PostPrincipale(
CodPost char(30) not null,
TitoloPost char(100) not null,
TimestampPubblicazione Timestamp not null,
Username char(60) not null,
Testo text not null,
StringaIndirizzoWeb char(120) default ' ',
AreaForum char(50) not null,
PRIMARY KEY(CodPost),
CONSTRAINT AutorePrincipale
FOREIGN KEY (Username)
REFERENCES ProfiloSocial(Username)
ON DELETE CASCADE
ON UPDATE CASCADE,
CONSTRAINT AreaAppartenenzaPrincipale
FOREIGN KEY (AreaForum)
REFERENCES AreaForum(NomeArea)
ON DELETE CASCADE
ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS PostRisposta(
CodPost char(30) not null,
TitoloPost char(100) not null,
TimestampPubblicazione timestamp not null,
Username char(60) not null,
Testo text not null,
StringaIndirizzoWeb char(120),
NumeroStelleTotali int DEFAULT 0,
PostPrincipale char(30) not null,
PRIMARY KEY(CodPost),
CONSTRAINT AutoreRisposta
FOREIGN KEY (Username)
REFERENCES ProfiloSocial(Username)
ON DELETE CASCADE
ON UPDATE CASCADE,
CONSTRAINT Risposta
FOREIGN KEY (PostPrincipale)
REFERENCES PostPrincipale(CodPost)
ON DELETE CASCADE
ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=latin1;

/*
CREATE TABLE IF NOT EXISTS Thread (
CodThread char(20) not null,
CodSfida char(20) not null,
PRIMARY KEY(CodThread,CodSfida),
CONSTRAINT PostSfidaPrincipale
FOREIGN KEY(CodThread)
REFERENCES PostPrincipale(CodPost)
ON DELETE CASCADE
ON UPDATE CASCADE,
CONSTRAINT PostSfidaRisposta
FOREIGN KEY(CodThread)
REFERENCES PostRisposta(CodPost)
ON DELETE CASCADE
ON UPDATE CASCADE,
CONSTRAINT SfidaThread
FOREIGN KEY (CodSfida)
REFERENCES Sfida(CodSfida)
ON DELETE CASCADE
ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=latin1;
*/
CREATE TABLE IF NOT EXISTS RichiestaAmicizia(
UtenteRichiedente char(60) not null,
UtenteDestinatario char(60) not null,
Stato char(15) not null,
PRIMARY KEY(UtenteRichiedente,UtenteDestinatario),
CONSTRAINT InvioRichiesta
FOREIGN KEY(UtenteRichiedente)
REFERENCES ProfiloSocial(Username)
ON DELETE CASCADE
ON UPDATE CASCADE,
CONSTRAINT RiceveRichiesta
FOREIGN KEY(UtenteDestinatario)
REFERENCES ProfiloSocial(Username)
ON DELETE CASCADE
ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=latin1;


CREATE TABLE IF NOT EXISTS Amicizia(
Utente1 char(60) not null,
Utente2 char(60) not null,
DataInizioAmicizia date not null,
PRIMARY KEY(Utente1,Utente2,DataInizioAmicizia),
CONSTRAINT Amicizia1
FOREIGN KEY(Utente1)
REFERENCES ProfiloSocial(Username)
ON DELETE CASCADE
ON UPDATE CASCADE,
CONSTRAINT Amicizia2
FOREIGN KEY(Utente2)
REFERENCES ProfiloSocial(Username)
ON DELETE CASCADE
ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS Interesse (
Username char(60) not null,
Interesse char(50) not null,
PRIMARY KEY(Username,Interesse),
CONSTRAINT InteresseUtente
FOREIGN KEY (Username)
REFERENCES ProfiloSocial(Username)
ON DELETE CASCADE
ON UPDATE CASCADE
)Engine=InnoDB DEFAULT CHARSET=latin1;



CREATE TABLE IF NOT EXISTS Cerchia(
CodCerchia char(20) not null,
NomeCerchia char(100) not null,
Utente char(60) not null,
Interesse1 char(50) default null,
Interesse2 char(50) default null,
Interesse3 char(50) default null,
NumeroPartecipantiCerchia int default 0,       
PRIMARY KEY(CodCerchia),
CONSTRAINT AmministratoreCerchia
FOREIGN KEY(Utente)
REFERENCES ProfiloSocial(Username)
ON UPDATE CASCADE
ON DELETE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS Consigliati (
Utente char(20) not null,
UtenteConsigliato char(20) not null,
Cerchia char(20) not null,
NumeroInteressiInComune int default 0,
PRIMARY KEY(Cerchia,UtenteConsigliato),
CONSTRAINT CerchiaRiferimento
FOREIGN KEY (Cerchia)
REFERENCES Cerchia(CodCerchia)
ON DELETE CASCADE
ON UPDATE CASCADE,
CONSTRAINT UtenteConsigliatoRiferimento
FOREIGN KEY (UtenteConsigliato)
REFERENCES ProfiloSocial(Username)
ON DELETE CASCADE
ON UPDATE CASCADE,
CONSTRAINT UtenteRiferimento
FOREIGN KEY (Utente)
REFERENCES ProfiloSocial(Username)
ON DELETE CASCADE
ON UPDATE CASCADE

)ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS ComposizioneCerchia(
Cerchia char(50) not null,
Utente char(50) not null,
PRIMARY KEY (Cerchia,Utente),
CONSTRAINT CerchiaPartecipazione
FOREIGN KEY (Cerchia)
REFERENCES Cerchia(CodCerchia)
ON DELETE CASCADE
ON UPDATE NO ACTION,
CONSTRAINT PartecipazioneCerchia
FOREIGN KEY(Utente)
REFERENCES ProfiloSocial(Username)
ON DELETE CASCADE
ON UPDATE NO ACTION
)ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS Visita(
CodVisita char(20) not null,
Medico char(16) not null,
Cliente char(16) not null,
DataVisita date not null,
OraVisita time not null,
ValutazioneFisica text not null,
PRIMARY KEY(CodVisita),
CONSTRAINT MedicoVisitante
FOREIGN KEY (Medico)
REFERENCES Medico(CodFiscale)
ON DELETE CASCADE
ON UPDATE CASCADE,
CONSTRAINT ClienteVisitato
FOREIGN KEY (Cliente)
REFERENCES Cliente(CodFiscale)
ON DELETE CASCADE
ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS Misurazione(
Peso int not null,
IndiceMassaMagra int not null,
IndiceMassaGrassa int not null,
IndiceAcqua int not null,
Visita char(20) not null,
PRIMARY KEY (Visita),
CONSTRAINT Visita_Misurazione
FOREIGN KEY (Visita)
REFERENCES Visita(CodVisita)
ON DELETE NO ACTION
ON UPDATE NO ACTION
)ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS AccessoCentro(
Cliente char(16) not null,
Centro char(20) not null,
DataAccesso date not null,
OrarioAccesso time not null,
ArmadiettoAssegnato char(20),
PasswordArmadietto char(8),
OrarioUscita time not null,
PRIMARY KEY(Cliente,Centro,DataAccesso,OrarioAccesso),
CONSTRAINT ClienteAccesso
FOREIGN KEY (Cliente)
REFERENCES Cliente(CodFiscale)
ON DELETE NO ACTION
ON UPDATE CASCADE,
CONSTRAINT CentroAccesso
FOREIGN KEY (Centro)
REFERENCES Centro(CodCentro)
ON DELETE NO ACTION
ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=latin1;


CREATE TABLE IF NOT EXISTS AccessoSala(
Cliente char(16) not null,
Sala char(20) not null,
DataAccesso date not null,
OrarioAccesso time not null,
OrarioUscita time not null,
PRIMARY KEY(Cliente,Sala,DataAccesso,OrarioAccesso),
CONSTRAINT ClienteAccessoSala
FOREIGN KEY (Cliente)
REFERENCES Cliente(CodFiscale)
ON DELETE NO ACTION
ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS Fornitore(
NomeAzienda char(80) not null,
FormaSocietaria char(30) not null,
PartitaIva char(25) not null,
Indirizzo char(30) not null,
Citta char(80) not null,
Telefono char(12) not null,
PRIMARY KEY(PartitaIVA)
)ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS Integratore(
NomeCommerciale char(30) not null,
Tipologia char(25) not null,
SostanzaContenuta char(80) not null,
NumeroPezziConfezione int not null,
QuantitaPerPezzo int not null,
Fornitore char(80) not null,
PRIMARY KEY(NomeCommerciale,Fornitore),
CONSTRAINT ChiFornisce
FOREIGN KEY (Fornitore)
REFERENCES Fornitore(PartitaIva)
ON DELETE CASCADE
ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=latin1;


CREATE TABLE IF NOT EXISTS Ordine(
CodOrdine char(30) not null,
Fornitore char(25) not null,
Centro char(20) not null,
Stato char(20) not null,
MetodoPagamento char(25) not null,
NumStockRichiesti int default 0,
PRIMARY KEY (CodOrdine),
CONSTRAINT Fornitura
FOREIGN KEY (Fornitore)
REFERENCES Fornitore(PartitaIVA)
ON DELETE NO ACTION
ON UPDATE CASCADE,
CONSTRAINT CentroInvioOrdine
FOREIGN KEY (Centro)
REFERENCES Centro(CodCentro)
ON DELETE NO ACTION
ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS OrdiniEvasi(
CodOrdine char(30) not null,
DataInvioOrdine date not null,
DataConsegnaPreferita date not null,
Stato char(20) not null,
PRIMARY KEY(CodOrdine),
CONSTRAINT OrdineRiferito
FOREIGN KEY (CodOrdine)
REFERENCES Ordine(CodOrdine)
ON DELETE CASCADE
ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS Acquisto(
CodOrdine char(30) not null,
CodProdotto char(30) not null,
NomeIntegratore char(60) not null,
Quantita int not null,
PRIMARY KEY(CodProdotto),
CONSTRAINT OrdineRiferimento
FOREIGN KEY (CodOrdine)
REFERENCES Ordine(CodOrdine)
ON DELETE CASCADE
ON UPDATE CASCADE,
CONSTRAINT IntegratoreRiferimento
FOREIGN KEY (NomeIntegratore)
REFERENCES Integratore(NomeCommerciale)
ON DELETE CASCADE
ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS Magazzino(
CodMagazzino char(25) not null,
Centro char(20) not null,
CapienzaMassima int not null,
CapienzaAttualeFisica int DEFAULT 0 not null,
CapienzaAttualeVirtuale int DEFAULT 0 not null,    /* trigger */
PRIMARY KEY(CodMagazzino),
CONSTRAINT CentroMagazzino
FOREIGN KEY (Centro)
REFERENCES Centro(CodCentro)
ON UPDATE CASCADE
ON DELETE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS MerceMagazzino(
CodProdotto char(30) not null,
Integratore char(60) not null,
Magazzino char(25) not null,
Quantita int not null,
DataScadenza date not null,
Rank char(10) ,
PRIMARY KEY(CodProdotto),
CONSTRAINT IntegratoreContenuto
FOREIGN KEY(Integratore)
REFERENCES Integratore(NomeCommerciale)
ON DELETE CASCADE
ON UPDATE CASCADE,
CONSTRAINT MagazzinoContenimento
FOREIGN KEY (Magazzino)
REFERENCES Magazzino(CodMagazzino)
ON DELETE CASCADE
ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS InventarioMagazzino(
Magazzino char(25) not null,
Integratore char(60) not null,
Costo INT not null,
QuantitàDeposito int default 0,
QuantitàOrdinata int default 0,
PRIMARY KEY(Magazzino,Integratore),
CONSTRAINT EsistenzaMagazzino
FOREIGN KEY(Magazzino)
REFERENCES Magazzino(CodMagazzino)
ON DELETE CASCADE
ON UPDATE CASCADE)
ENGINE=InnoDB  DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS Vendite(
CodVendita char(25) not null,
Cliente char(16) not null,
Centro char(20) not null,
Integratore char(30) not null,
DataVendita date not null,
Quantita int not null,
PRIMARY KEY (CodVendita),
CONSTRAINT Vendita_Centro
FOREIGN KEY(Centro)
REFERENCES Centro(CodCentro)
ON DELETE CASCADE
ON UPDATE CASCADE,
CONSTRAINT Vendita_Integratore 
FOREIGN KEY(Integratore)
REFERENCES Integratore(NomeCommerciale)
ON DELETE CASCADE
ON UPDATE CASCADE,
CONSTRAINT Vendita_CLiente
FOREIGN KEY(Cliente)
REFERENCES Cliente(CodFiscale)
ON DELETE CASCADE
ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=latin1;



CREATE TABLE IF NOT EXISTS Giudizio (
Username char(60) not null,
Codpost char(30)  not null,
VotoStelle int default 0,
PRIMARY KEY(Username,codpost),
CONSTRAINT UsernameEsistente
FOREIGN KEY (username)
REFERENCES Profilosocial(username)
ON DELETE NO ACTION
ON UPDATE CASCADE,
CONSTRAINT PostEsistente
FOREIGN KEY (codpost)
REFERENCES postrisposta(codpost)
ON DELETE CASCADE
ON UPDATE CASCADE
)Engine=InnoDB DEFAULT CHARSET=latin1;


CREATE TABLE IF NOT EXISTS SchedaAllenamento(
CodSchedaAllenamento Char(15) not null,
Cliente char(16) not null,
DataEmissione date not null,
DataInizio date not null,
DataFine date not null,
Tutor char(16) not null,
PRIMARY KEY(CodSchedaAllenamento),
CONSTRAINT TutorRiferimento
FOREIGN KEY (Tutor)
REFERENCES Istruttore(CodFiscale)
ON DELETE NO ACTION
ON UPDATE CASCADE,
CONSTRAINT ClienteRiferimento
FOREIGN KEY (Cliente)
REFERENCES Cliente(CodFiscale)
ON UPDATE CASCADE
ON DELETE NO ACTION
)ENGINE=InnoDB DEFAULT CHARSET=latin1;


CREATE TABLE IF NOT EXISTS Esercizio(
CodEsercizio char(10) not null,
Nome char(50) not null,
TipoEsercizio char(15) not null,
DispendioEnergeticoMedio int,
DurataInMinuti int ,
NumeroRipetizioni int ,
NumeroSerie int ,
TempodirecuperoSecondi int not null,
PRIMARY KEY(CodEsercizio)
)ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS EsercizioScheda(
Scheda char(15) not null,
Esercizio char(10) not null,
Giorno int not null,
PRIMARY KEY(Scheda,Esercizio,Giorno),
CONSTRAINT SchedaRiferimentoEs
FOREIGN KEY(Scheda)
REFERENCES SchedaAllenamento(CodSchedaAllenamento)
ON UPDATE CASCADE
ON DELETE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=latin1;



CREATE TABLE IF NOT EXISTS Attrezzatura(
CodAttrezzatura char(20) not null,
Tipologia char(80) not null,
LivelloDiUsuraPercentuale int not null,
Funzionante bool not null,
Sala char(20),
PRIMARY KEY (CodAttrezzatura),
CONSTRAINT SalaAttrezzatura
FOREIGN KEY (Sala)
REFERENCES Sala(CodSala)
ON DELETE SET NULL
ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=latin1;


CREATE TABLE IF NOT EXISTS Esercizio_Attrezzatura (
Esercizio CHAR(50) not null,
Attrezzatura CHAR(20) not null,
PRIMARY KEY(Esercizio,Attrezzatura),
CONSTRAINT Attrezzatura_Esercizio
FOREIGN KEY (Attrezzatura)
REFERENCES Attrezzatura(CodAttrezzatura)
ON DELETE CASCADE
ON UPDATE NO ACTION
)ENGINE=InnoDB DEFAULT CHARSET=latin1;


CREATE TABLE IF NOT EXISTS Esercizio_Configurazione(
Esercizio char(20) not null,
Attrezzatura CHAR(80),
TipoConfigurazione CHAR(50),
ValoreConfigurazione INT DEFAULT 0 ,
PRIMARY KEY(Esercizio,Attrezzatura,TipoConfigurazione),
CONSTRAINT Esercizio_Scheda
FOREIGN KEY (Esercizio)
REFERENCES Esercizio(CodEsercizio)
ON DELETE NO ACTION
ON UPDATE NO ACTION
)ENGINE=InnoDB DEFAULT CHARSET=latin1;


CREATE TABLE IF NOT EXISTS EsercizioSvolto(
Cliente CHAR(16) not null,
Esercizio CHAR(10) not null,
IstanteInizio TIMESTAMP not null,
SchedaAllenamento CHAR(20),
Ripetizioni int ,
NumeroSerie int,
Durata INT ,
TempodiRecupero INT not null,              /*Espresso in secondi */
GiornoScheda INT default 0,
Sala CHAR(20) not null,
Sfida CHAR(20),
PRIMARY KEY (Cliente,Esercizio,IstanteInizio),
CONSTRAINT Esercizio_Svolto
FOREIGN KEY(Esercizio)
REFERENCES Esercizio(CodEsercizio)
ON DELETE CASCADE 
ON UPDATE CASCADE,
CONSTRAINT Esercizio_Svolto_Scheda
FOREIGN KEY (SchedaAllenamento)
REFERENCES SchedaAllenamento(CodSchedaAllenamento)
ON DELETE CASCADE 
ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=latin1;


CREATE TABLE EsercizioSvolto_Configurazione(
Cliente CHAR(16) not null,
Esercizio CHAR(10) not null,
IstanteInizio TIMESTAMP not null,
Attrezzatura CHAR(50) not null,
TipoConfigurazione CHAR(80) ,
ValoreConfigurazione INT,
PRIMARY KEY(Cliente,Esercizio,IstanteInizio,Attrezzatura,TipoConfigurazione),
CONSTRAINT Eserciziosvolto_Target
FOREIGN KEY (Cliente,Esercizio,IstanteInizio)
REFERENCES EsercizioSvolto(Cliente,Esercizio,IstanteInizio)
ON DELETE CASCADE
ON UPDATE NO ACTION,
CONSTRAINT Esercizio_Attrezzatura
FOREIGN KEY (Attrezzatura)
REFERENCES Attrezzatura(CodAttrezzatura)
ON DELETE NO ACTION
ON UPDATE NO ACTION
)ENGINE=InnoDB DEFAULT CHARSET=latin1;




CREATE TABLE IF NOT EXISTS AreaAllestibile(
CodArea char(20) not null,
Sede char(20) not null,
Locazione char(10) CHECK (Locazione='interno' or Locazione = 'esterno'),
MaxNumeroPersone int not null,
MinNumeroPersone int not null,
PRIMARY KEY(CodArea),
CONSTRAINT FK_Sede
FOREIGN KEY (Sede)
REFERENCES Centro(CodCentro)
ON DELETE CASCADE
ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS TariffeAreeAllestibili(
TipoArea char(30) not null,
CodArea char(20) not null,
TariffaOrariaPerPersona double not null,
TariffaAttrezzattura double default null,
PRIMARY KEY (TipoArea,CodArea),
CONSTRAINT AreaRif
FOREIGN KEY (CodArea)
REFERENCES AreaAllestibile(CodArea)
ON DELETE CASCADE
ON UPDATE CASCADE
)Engine=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS Prenotazione(
CodPrenotazione char(30) not null,
Area char(20) not null,
TipoArea char(30) not null,
AttrezzaturaParticolareRichiesta bool,
ClienteRichiedente char(50) not null,
DataInvioPrenotazione timestamp not null,
DataAttivita date not null,
InizioAttivita time not null,
FineAttivita time not null,
Stato char(30) not null,
PunteggioGruppo int not null,
NumPartecipanti int not null,
PRIMARY KEY (CodPrenotazione),
CONSTRAINT Prenota_Cliente
FOREIGN KEY (ClienteRichiedente)
REFERENCES Cliente(CodFiscale)
ON DELETE CASCADE
ON UPDATE CASCADE,
CONSTRAINT Prenota_Area
FOREIGN KEY (Area)
REFERENCES AreaAllestibile(CodArea)
ON DELETE CASCADE
ON UPDATE CASCADE,
CONSTRAINT AreaRiferimento
FOREIGN KEY (TipoArea)
REFERENCES TariffeAreeAllestibili(TipoArea)
ON DELETE CASCADE
ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=latin1;


CREATE TABLE IF NOT EXISTS Partecipante(
Cliente char(16) not null,
CodPrenotazione char(30) not null,
PRIMARY KEY(CodPrenotazione,Cliente),
CONSTRAINT Partecipante_cliente
FOREIGN KEY (Cliente)
REFERENCES Cliente(CodFiscale)
ON DELETE CASCADE
ON UPDATE CASCADE,
CONSTRAINT Partecipante_Prenotazione
FOREIGN KEY (CodPrenotazione)
REFERENCES Prenotazione(CodPrenotazione)
ON DELETE CASCADE
ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS PrenotazioneAlternativa (
CodPrenotazione char(30) not null,
DataAlternativa date not null,
OrarioInizioAlternativo time not null,
OrarioFineAlternativo time not null,
DataInoltroPrenotazione timestamp not null,
PRIMARY KEY(codprenotazione,dataalternativa,orarioinizioalternativo,
            orariofinealternativo),
CONSTRAINT PrenotazioneDiRiferimento
FOREIGN KEY (CodPrenotazione)
REFERENCES Prenotazione(CodPrenotazione)
ON DELETE CASCADE
ON UPDATE CASCADE
)Engine=InnoDB DEFAULT CHARSET=latin1;



CREATE TABLE IF NOT EXISTS SaldoAreeAllestibiliCliente(
Cliente char(16) not null,
SaldoMese double default 0,
SaldoTotale double default 0 , 
Centro char(20) not null,
PRIMARY KEY(Cliente,Centro),
CONSTRAINT ClientePagamento
FOREIGN KEY (Cliente)
REFERENCES Cliente(CodFiscale)
ON DELETE NO ACTION                 /* se il cliente è eliminato deve comunque pagare il mese */
ON UPDATE CASCADE,
CONSTRAINT REF_Sede
FOREIGN KEY (Centro)
REFERENCES Centro(CodCentro)
)Engine=InnoDB DEFAULT CHARSET=latin1;


CREATE TABLE IF NOT EXISTS SaldiAreeAllestibiliDaPagare(
Cliente char(16) not null,
Saldo double not null,
Mese char(15) not null,
Anno int not null,
StatoSaldo char(15) not null,
Centro char(20) not null,
PRIMARY KEY(Cliente,Mese,Anno,Centro),
CONSTRAINT SedeSaldo
FOREIGN KEY (Centro)
REFERENCES Centro(CodCentro)
ON DELETE NO ACTION 
ON UPDATE CASCADE,
CONSTRAINT ClienteArea
FOREIGN KEY (Cliente)
REFERENCES Cliente(CodFiscale)
ON DELETE NO ACTION
ON UPDATE CASCADE
) Engine=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS Sfida(
CodSfida char(20) not null,
TitoloSfida char(80) not null,
UtenteProponente char(60) not null,
DataLancioSfida date not null,
DataInizioSfida date not null,
DataFineSfida date not null,
ScopoDaRaggiungere char(80) not null,
ValoreScopo int not null,
SchedaAllenamento char(50) ,
SchedaAlimentazione char(50) ,
CodPost char(60) not null,
NumeroPartecipanti int DEFAULT 0,    /* trigger */
PRIMARY KEY(CodSfida),     
CONSTRAINT Proponente
FOREIGN KEY(UtenteProponente)
REFERENCES ProfiloSocial(Username)
ON UPDATE CASCADE
ON DELETE NO ACTION,
CONSTRAINT CodPostSfida
FOREIGN KEY(CodPost)
REFERENCES Postprincipale(Codpost)
ON UPDATE CASCADE
ON DELETE CASCADE,
CONSTRAINT SchedaAlimentazioneSfida
FOREIGN KEY(SchedaAlimentazione)
REFERENCES SchedaAlimentazione(CodSchedaAlim)
ON UPDATE CASCADE
ON DELETE SET NULL,
CONSTRAINT SchedaAllenamentoSfida
FOREIGN KEY(SchedaAllenamento)
REFERENCES SchedaAllenamento(CodSchedaAllenamento)
ON UPDATE CASCADE
ON DELETE SET NULL
)ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS Sforzo(
CodSforzo char(20) not null,
CodSfida char(20) not null,
Username char(60) not null,
ValoreSforzo int not null,
DataSforzo date not null,
PRIMARY KEY(CodSforzo),
CONSTRAINT UserSforzo
FOREIGN KEY (Username)
REFERENCES ProfiloSocial(Username)
ON UPDATE CASCADE
ON DELETE CASCADE,
CONSTRAINT SfidaSforzo
FOREIGN KEY (CodSfida)
REFERENCES Sfida(CodSfida)
ON UPDATE CASCADE
ON DELETE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS SfidaConclusa(
CodSfida char(20) not null,
Username char(60) not null,
DataConclusione date not null,
VotoSfida double not null,
PRIMARY KEY(CodSfida,Username,DataConclusione),
CONSTRAINT UserConclude
FOREIGN KEY(Username)
REFERENCES ProfiloSocial(Username)
ON UPDATE CASCADE
ON DELETE CASCADE,
CONSTRAINT SfidaConclude
FOREIGN KEY(CodSfida)
REFERENCES Sfida(CodSfida)
ON UPDATE CASCADE
ON DELETE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=latin1;


CREATE TABLE IF NOT EXISTS Esercizio_Modifica(
Esercizio char(20) not null,
Sfida CHAR(20) not null,
Ripetizioni int ,
NumeroSerie int,
Durata INT ,
TempodiRecupero INT not null,              /*Espresso in secondi */
GiornoScheda INT default 0,
PRIMARY KEY(Esercizio,Sfida,GiornoScheda),
CONSTRAINT EsercizioScheda_Modifica
FOREIGN KEY (Esercizio)
REFERENCES Esercizio(CodEsercizio)
ON DELETE NO ACTION
ON UPDATE NO ACTION,
CONSTRAINT EsercizioperSfida
FOREIGN KEY(Sfida)
REFERENCES Sfida(CodSfida)
ON DELETE CASCADE
ON UPDATE NO ACTION
)ENGINE=InnoDB DEFAULT CHARSET=latin1;




CREATE TABLE IF NOT EXISTS Esercizio_Modifica_Config(
Esercizio char(20) not null,
Sfida CHAR(20) not null,
GiornoScheda INT not null,
Attrezzatura CHAR(80) not null,
TipologiaConfigurazione CHAR(60) not null,
ValoreConfigurazione INT not null,
PRIMARY KEY(Esercizio,Sfida,Attrezzatura,TipologiaConfigurazione),
CONSTRAINT EsercizioScheda_ModificaConfig
FOREIGN KEY (Esercizio,Sfida,GiornoScheda)
REFERENCES Esercizio_Modifica(Esercizio,Sfida,GiornoScheda)
ON DELETE NO ACTION
ON UPDATE NO ACTION
)ENGINE=InnoDB DEFAULT CHARSET=latin1;




CREATE TABLE IF NOT EXISTS Modifiche_SchedaAlimentazione (
Sfida CHAR(20) not null,
ApportoCaloricoGiornaliero INT not null,
NumeroPasti INT not null,
ComposizionePasti TEXT not null,
PRIMARY KEY(Sfida),
CONSTRAINT ModificaAlimentazione_Sfida
FOREIGN KEY (Sfida)
REFERENCES Sfida(CodSfida)
ON DELETE CASCADE
ON UPDATE NO ACTION
)ENGINE=InnoDB DEFAULT CHARSET=latin1;




CREATE TABLE IF NOT EXISTS AderisciSfida(
Utente char(60) not null,
CodSfida char(20) not null,
PRIMARY KEY(Utente,CodSfida),
CONSTRAINT UtentePartecipante
FOREIGN KEY(Utente)
REFERENCES ProfiloSocial(Username)
ON DELETE CASCADE
ON UPDATE CASCADE,
CONSTRAINT AdesioneSfida
FOREIGN KEY(CodSfida)
REFERENCES Sfida(CodSfida)
ON DELETE CASCADE
ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=latin1;


CREATE TABLE IF NOT EXISTS MisurazioneSfida (
Sfida CHAR(20) not null,
ValoreMisurazione INT not null,
Visita CHAR(20) not null,
PRIMARY KEY(Visita),
CONSTRAINT Misurazione_Sfida
FOREIGN KEY (Sfida)
REFERENCES Sfida(CodSfida)
ON DELETE CASCADE
ON UPDATE CASCADE,
CONSTRAINT VisitaMisurazione_Sfida
FOREIGN KEY (Visita)
REFERENCES Visita(CodVisita)
ON DELETE NO ACTION
ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET= latin1;





CREATE TABLE IF NOT EXISTS Piscina (
CodPiscina CHAR(20) not null,
Centro CHAR(20) not null,
Interno BOOL not null,
ResponsabilePiscina CHAR(16) not null,
TariffaOraria DOUBLE not null,
PRIMARY KEY (CodPiscina),
CONSTRAINT Centro_Piscina
FOREIGN KEY(Centro)
REFERENCES Centro(CodCentro)
ON DELETE CASCADE
ON UPDATE NO ACTION,
CONSTRAINT Resonsabile_Piscina
FOREIGN KEY (ResponsabilePiscina)
REFERENCES Responsabile(Responsabile)
ON DELETE NO ACTION
ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=latin1;





CREATE TABLE IF NOT EXISTS AccessoSala_Medica (
Cliente CHAR(16) not null,
Centro CHAR(50) not null,
DataAccesso DATE not null,
OrarioAccesso TIME not null,
OrarioUscita TIME not null,
PRIMARY KEY (Cliente,Centro,DataAccesso,OrarioAccesso),
CONSTRAINT ClienteAccesso_SalaMedica
FOREIGN KEY (Cliente)
REFERENCES Cliente(CodFiscale)
ON DELETE CASCADE
ON UPDATE CASCADE,
CONSTRAINT CentroAccesso_SalaMedica
FOREIGN KEY (Centro)
REFERENCES Centro(CodCentro)
ON DELETE NO ACTION
ON UPDATE NO ACTION
)ENGINE=InnoDB DEFAULT CHARSET=latin1;


CREATE TABLE IF NOT EXISTS Accesso_Pagato (
Cliente CHAR(16) not null,
Sala CHAR(20) not null,
Prezzo DOUBLE not null,
DataAccesso DATE not null,
OrarioIngresso TIME not null,
OrarioUscita TIME,
PRIMARY KEY(Cliente,Sala,DataAccesso,OrarioIngresso),
CONSTRAINT Cliente_AccessoPagato
FOREIGN KEY(Cliente)
REFERENCES Cliente(CodFiscale)
ON DELETE CASCADE
ON UPDATE NO ACTION,
CONSTRAINT Sala_AccessoPagato
FOREIGN KEY (Sala)
REFERENCES Sala(CodSala)
ON DELETE NO ACTION
ON UPDATE NO ACTION
)ENGINE=InnoDB DEFAULT CHARSET=latin1;


CREATE TABLE IF NOT EXISTS Vincitore_Sfida (
Sfida CHAR(20) not null,
Vincitore CHAR(60) not null,
PRIMARY KEY(Sfida,Vincitore),
CONSTRAINT Sfida_Vinta
FOREIGN KEY(Sfida)
REFERENCES Sfida(CodSfida)
ON DELETE CASCADE
ON UPDATE NO ACTION,
CONSTRAINT Vincitore_Sfida
FOREIGN KEY(Vincitore)
REFERENCES ProfiloSocial(Username)
ON DELETE CASCADE
ON UPDATE NO ACTION
)ENGINE=InnoDB DEFAULT CHARSET=latin1;





/* LOG TABLES */

CREATE TABLE IF NOT EXISTS Log_Sfide (
Sfida CHAR(20) not null,
PRIMARY KEY (Sfida)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


CREATE TABLE IF NOT EXISTS Log_Conclusioni (
Sfida CHAR(20) not null,
Username CHAR(60) not null,
PRIMARY KEY (Sfida,Username)
)ENGINE=InnoDB DEFAULT CHARSET=latin1;


CREATE TABLE IF NOT EXISTS Log_SalaMedica (
Cliente CHAR(16) not null,
Centro CHAR(50) not null,
DataAccesso DATE not null,
OrarioAccesso TIME not null,
PRIMARY KEY (Cliente)
)ENGINE=InnoDB DEFAULT CHARSET=latin1;


CREATE TABLE IF NOT EXISTS Log_Accesso (
Cliente char(16) not null,
Centro char(20) not null,
DataAccesso date not null,
OrarioAccesso time not null,
ArmadiettoAssegnato char(20),
PasswordArmadietto char(8),
PRIMARY KEY(Cliente)
)ENGINE=InnoDB DEFAULT CHARSET=latin1;




CREATE TABLE IF NOT EXISTS Log_AccessoPagato (
Cliente char(16) not null,
Sala char(20) not null,
DataAccesso date not null,
OrarioAccesso time not null,
PRIMARY KEY(Cliente)
)ENGINE=InnoDB DEFAULT CHARSET=latin1;



CREATE TABLE IF NOT EXISTS Log_Sala(
Cliente char(16) not null,
Sala char(20) not null,
DataAccesso date not null,
OrarioAccesso time not null,
PRIMARY KEY(Cliente)
)ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE Log_VenditeIntegratori(
codvendita char(25) not null,
integratore char(60) not null,
quantita INT not null,
guadagno DOUBLE not null,
centro char(20) not null,
PRIMARY KEY(codvendita))
Engine=InnoDB DEFAULT CHARSET=latin1;


CREATE TABLE ReportIntegratori(
Centro char(20) not null,
Tipologia char(25) not null,
Integratore char(60) not null,
QuantitaVenduta INT ,
GuadagnoTotale DOUBLE,
LottoPiuVicinoAllaScadenza CHAR(30) not null,
GiorniAllaScadenza INT ,
PRIMARY KEY(Centro,Integratore)
)Engine=InnoDB DEFAULT CHARSET=latin1;


CREATE TABLE IF NOT EXISTS LogPerformance(
DataAnalisi TIMESTAMP not null,
Cliente CHAR(16) not null,
EsercizioScheda char(50),
TempoRecupero  char (80) ,
SvolgimentoEsercizio char(80) ,
FedeltaAttrezzature char(80) ,
PRIMARY KEY(DataAnalisi,Cliente))
Engine=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS MV_Piscine_Aree(
DataEsecuzione TIMESTAMP not null,
PercentualeUtilizzoPiscine DOUBLE not null,
PercentualeUtilizzoAree DOUBLE not null,
PRIMARY KEY (DataEsecuzione)
)ENGINE=InnoDB DEFAULT CHARSET=latin1;


CREATE TABLE IF NOT EXISTS MV_UtilizzoAttrezzatura (
DataEsecuzione TIMESTAMP not null,
Centro CHAR(20) not null,
CodAttrezzatura CHAR(20) not null,
TipologiaAttrezzatura CHAR(80) not null,
NumeroUtilizzi INT not null,
PRIMARY KEY(CodAttrezzatura)
)ENGINE=InnoDB DEFAULT CHARSET=latin1;


CREATE TABLE IF NOT EXISTS MV_ResocontoCorsi (
DataEsecuzione TIMESTAMP not null,
Corso CHAR(20) not null,
NumeroFrequentatori INT not null,
PRIMARY KEY(Corso)
)ENGINE=InnoDB DEFAULT CHARSET=latin1;


CREATE TABLE IF NOT EXISTS MV_FasceOrarie (
DataEsecuzione TIMESTAMP not null,
Centro CHAR(20) not null,
Da TIME not null,
A TIME not null,
NumeroAccessi INT not null,
PRIMARY KEY (Centro,Da,A)
)ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS Log_Sfida (
Sfida CHAR(20) not null,
PRIMARY KEY (Sfida)
)ENGINE=InnoDB DEFAULT CHARSET=latin1;
