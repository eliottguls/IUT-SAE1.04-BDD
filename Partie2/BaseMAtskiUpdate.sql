-- changer les categories et article --> codetype à enlever de la class article
-- Un contact est spécifique à un client id par un numerodecontact numcontact= type serial pour eviter les cases vides --> on a au moins un contact à chaque fois/
-- Pour les homonymes de contact on va dire que peu importe car on va demander un cintact à partir du clien
-- conctact est une composition, le contact est un composant du client
-- where nomcontact2 is not null (pour ajouter le contact si le nom de contact est pas nul



/* 
=========================================
=        Update de la BDD matski        =
=========================================
*/
drop schema if exists matski_update cascade;
create schema matski_update;
set schema 'matski_update';



/****************************************
*         Table : _typearticle          *
****************************************/
create table _typearticle(
  codetype      CHAR(1)     not null,
  libelletype   VARCHAR(40) not null,
  constraint PK_TYPEARTICLE primary key (codetype)
);

insert into _typearticle(codetype,libelletype)
  select codetype, libelletype
  from matski.typearticle;

/****************************************
*           Table : _article            *
****************************************/
create table _article(
  numarticle        SERIAL        not null,
  nomarticle        CHAR(20)      not null,
  referenceinterne  CHAR(10)      not null,
  codebarre         CHAR(13)      not null,
  codetype          CHAR(1)       not null,
  coutachat         NUMERIC(10,2) not null,
  prixVente         NUMERIC(10,2) not null,
  constraint PK_ARTICLE primary key (numarticle)
);


ALTER TABLE _article
  ADD CONSTRAINT fk_article_estlie_typearti FOREIGN KEY (codetype)
  REFERENCES matski.TYPEARTICLE (codetype);

insert into _article(numarticle, nomarticle, referenceinterne,codebarre,codetype,coutachat,prixVente)
  select numarticle,nomarticle,referenceinterne,codebarre,codetype,coutachat, prixvente
  from matski.ARTICLE;
  


/****************************************
*           Table : _listeprix          *
****************************************/
CREATE TABLE _listeprix
(
   codeliste     char(1)       NOT NULL,
   libelleliste  varchar(20)   NOT NULL
);

ALTER TABLE _listeprix
   ADD CONSTRAINT pk_listeprix
   PRIMARY KEY (codeliste);
   
insert into _listeprix(codeliste,libelleliste)
  select codeliste,libelleliste
  from matski.LISTEPRIX;


/****************************************
*           Table : _tarifvente         *
****************************************/
CREATE TABLE _tarifvente
(
   numarticle  integer         NOT NULL,
   codeliste   char(1)         NOT NULL,
   prixVente   numeric(10,2)   NOT NULL
);

ALTER TABLE _tarifvente
   ADD CONSTRAINT pk_tarifvente
   PRIMARY KEY (numarticle, codeliste);

ALTER TABLE _tarifvente
  ADD CONSTRAINT fk_tarifvente_tarifvent_article FOREIGN KEY (numarticle)
  REFERENCES matski.article (numarticle) ;


ALTER TABLE _tarifvente
  ADD CONSTRAINT fk_tarifven_tarifvent_listepri FOREIGN KEY (codeliste)
  REFERENCES matski.listeprix (codeliste) ;


INSERT INTO _tarifvente(numarticle,codeliste, prixvente)
  select numarticle, codeliste, prixvente
  from matski.tarifvente;
  
/****************************************
*           Table : _etiquette           *
****************************************/
CREATE TABLE _etiquette
(
   codeEtiquette     char(3)       NOT NULL,
   libelleEtiquette  varchar(70)   NOT NULL,
   codeTypetva       integer       NOT NULL
);

ALTER TABLE _etiquette
   ADD CONSTRAINT pk_etiquette
   PRIMARY KEY (codeetiquette);
   
INSERT INTO _etiquette(codeEtiquette,libelleEtiquette, codeTypetva)
  select codeetiquette, libelleetiquette, codeTypetva
  from matski.etiquette;


/****************************************
*           Table : _client             *
****************************************/
CREATE TABLE _client(
  numClient                 serial      not null,
  codeListe                 char(1)     not null,
  codeEtiquette             char(3)     not null,
  nomClient                 varchar(50) not null,
  adresseRueClient          varchar(40) not null,
  adresseCodePostalClient   char(5)     not null,
  adresseVilleClient        varchar(20) not null,
  adressePaysClient         varchar(15) not null,
  telephoneClient           varchar(15) not null,
  mailClient                varchar(40) not null
  );
  
ALTER TABLE _client
   ADD CONSTRAINT pk_client
   PRIMARY KEY (numClient);

ALTER TABLE _client
  ADD CONSTRAINT fk_client_regroupe_etiquette FOREIGN KEY (codeetiquette)
  REFERENCES _etiquette (codeetiquette);
ALTER TABLE _client
  ADD CONSTRAINT fk_client_dispose_listeprix FOREIGN KEY (codeliste)
  REFERENCES _listeprix (codeliste);
  
INSERT INTO _client(numClient,codeListe,codeEtiquette,nomClient,adresseRueClient,adresseCodePostalClient,adresseVilleClient,adressePaysClient,telephoneClient,mailClient)
  SELECT numclient,codeliste,codeetiquette,nomclient,adresserueclient,adressecodepostalclient,adressevilleclient,adressepaysclient,telephoneclient,mailclient
  FROM matski.client;
  

  
/****************************************
*           Table : _commande           *
****************************************/
CREATE TABLE _commande
(
   numcommande   serial   NOT NULL,
   numclient     integer  NOT NULL,
   datecommande  date     NOT NULL,
   montantfrais  float    NOT NULL,
   montantht     float    NOT NULL,
   montantttc    float    NOT NULL
);


ALTER TABLE _commande
   ADD CONSTRAINT pk_commande
   PRIMARY KEY (numcommande);

ALTER TABLE _commande
  ADD CONSTRAINT fk_commande_appartient_client FOREIGN KEY (numclient)
  REFERENCES _client(numClient);
  

INSERT INTO _commande(numcommande,numclient,datecommande,montantfrais,montantht,montantttc)
  SELECT numcommande,numclient,datecommande,montantfrais,montantht,montantttc
  FROM matski.commande;
  
/****************************************
*           Table : _detailCommande     *
****************************************/
CREATE TABLE _detailCommande
(
  numCommande         int   not null,
  numarticle          int   not null,
  quantiteCommandee   int   not null,
  quantiteLivree      int   not null
 );
 
ALTER TABLE _detailcommande
   ADD CONSTRAINT pk_detailcommande
   PRIMARY KEY (numCommande, numarticle);

ALTER TABLE _detailcommande
  ADD CONSTRAINT fk_detailco_detailcom_article FOREIGN KEY (numarticle)
  REFERENCES _article (numarticle);
  
ALTER TABLE _detailcommande
  ADD CONSTRAINT fk_detailco_detailcom_commande FOREIGN KEY (numCommande)
  REFERENCES _commande (numcommande);
  

INSERT INTO _detailCommande(numCommande,numarticle,quantiteCommandee,quantiteLivree)
  SELECT numcommande,numarticle,quantiteCommandee,quantiteLivree
  FROM matski.detailcommande;
  
/****************************************
*           Table : _categorie          *
****************************************/
CREATE TABLE _categorie
(
  num_cat             serial         not null,
  libellecategorie    varchar(30)    not null
);


ALTER TABLE _categorie
    ADD CONSTRAINT pk_categorie
    PRIMARY KEY (num_cat);
    
INSERT INTO _categorie VALUES('1','Matériel ski alpins');
INSERT INTO _categorie VALUES('2','Matériel de snowboard');
INSERT INTO _categorie VALUES('3','Matériel ski nordique');
INSERT INTO _categorie VALUES('4','Matériel ski montagne');
INSERT INTO _categorie VALUES('5','Chaussures');
INSERT INTO _categorie VALUES('6','Skis');
INSERT INTO _categorie VALUES('7','Batons');
INSERT INTO _categorie VALUES('8','Chaussures');
INSERT INTO _categorie VALUES('9','Snowboard');
INSERT INTO _categorie VALUES('10','Chaussures');
INSERT INTO _categorie VALUES('11','Batons');
INSERT INTO _categorie VALUES('12','Skis');
INSERT INTO _categorie VALUES('13','Paret');
INSERT INTO _categorie VALUES('14','Luges');
INSERT INTO _categorie VALUES('15','Polyvalent');
INSERT INTO _categorie VALUES('16','Freestyle');
INSERT INTO _categorie VALUES('17','Racing');
INSERT INTO _categorie VALUES('18','Freeride');
INSERT INTO _categorie VALUES('19','Randonnée');
INSERT INTO _categorie VALUES('20','Polyvalent');
INSERT INTO _categorie VALUES('21','Freestyle');
INSERT INTO _categorie VALUES('22','Alpine');
INSERT INTO _categorie VALUES('23','Freeride');
INSERT INTO _categorie VALUES('24','Skating');
INSERT INTO _categorie VALUES('25','Alternatif');

/****************************************
*           Table : _sedecompose        *
****************************************/
CREATE TABLE _sedecompose(
  num_cat_sous      int not null,
  num_cat_sup       int not null
  );
  
ALTER TABLE _sedecompose
  ADD CONSTRAINT  fk_categorie_souscat_sedecompose FOREIGN KEY(num_cat_sous)
  REFERENCES matski.categorie(numcategorie);
  
ALTER TABLE _sedecompose
  ADD CONSTRAINT fk_sedecompose_catnumcategorie2_categorie FOREIGN KEY(num_cat_sup)
  REFERENCES matski.categorie(numcategorie);
  
INSERT INTO _sedecompose VALUES('5','1');
INSERT INTO _sedecompose VALUES('6','1');
INSERT INTO _sedecompose VALUES('7','1');
INSERT INTO _sedecompose VALUES('8','2');
INSERT INTO _sedecompose VALUES('9','2');
INSERT INTO _sedecompose VALUES('10','3');
INSERT INTO _sedecompose VALUES('11','3');
INSERT INTO _sedecompose VALUES('12','3');
INSERT INTO _sedecompose VALUES('13','4');
INSERT INTO _sedecompose VALUES('14','4');
INSERT INTO _sedecompose VALUES('15','6');
INSERT INTO _sedecompose VALUES('16','6');
INSERT INTO _sedecompose VALUES('17','6');
INSERT INTO _sedecompose VALUES('18','6');
INSERT INTO _sedecompose VALUES('19','6');
INSERT INTO _sedecompose VALUES('20','9');
INSERT INTO _sedecompose VALUES('21','9');
INSERT INTO _sedecompose VALUES('22','9');
INSERT INTO _sedecompose VALUES('23','9');
INSERT INTO _sedecompose VALUES('24','12');
INSERT INTO _sedecompose VALUES('25','12');




/****************************************
*           Table : _contact            *
****************************************/
CREATE TABLE _contact(
  numClient         int           not null,
  numContact        serial        not null,
  nomContact        varchar(20)   not null,
  telephoneContact  varchar(20)   not null,
  fonctionContact   varchar(40)   not null
  );
  
ALTER TABLE _contact
  ADD CONSTRAINT pk_contact
  PRIMARY KEY (numContact);
  
ALTER TABLE _contact
  ADD CONSTRAINT fk_contact_represente_client FOREIGN KEY (numClient)
  REFERENCES _client(numClient);
  
INSERT INTO _contact(numClient,numContact,nomContact,telephoneContact, fonctionContact) VALUES
  ('1','1','Fallon','043423245477','Commercial'),
  ('1','2','Colquit','043423245478','Responsable'),
  ('2','3','Darigan','043623245477','Responsable ventes'),
  ('2','4','Caney','043623245478','Commercial'),
  ('3','5','Mudrell','044023245477','Acheteur'),
  ('3','6','Layton','044023245478','Responsable'),
  ('4','7','Betser','044223245477','Vendeur'),
  ('4','8','Polet','044223245478','Accueil'),
  ('5','9','Weaver','044423245477','Commercial'),
  ('5','10','Doge','043423245478','Responsable'),
  ('6','11','Noades','043423245477','Acheteur'),
  ('6','12','Stegers','043423245478','Commercial'),
  ('7','13','Alessandrucci','043423245477','Accueil'),
  ('7','14','Rosson','043423245478','Responsable'),
  ('8','15','Veermer','0336237251','Accueil'),
  ('8','16','Keerl','0336237252','Responsable ventes'),
  ('9','17','Riddeough','0337237251','Acheteur'),
  ('9','18','Fitz','0337237252','Commercial'),
  ('10','19','Maclan','0337237251','Commercial'),
  ('10','20','Saudra','0337237252','Responsable ventes'),
  ('11','21','Paolino','0334237251','Accueil'),
  ('11','22','Odde','0334237252','Commercial'),
  ('12','23','Emeney','43535666604','Accueil'),
  ('13','24','Keymer','43535666604','Accueil'),
  ('13','25','Dutteridge','43535666605','Vendeurrcial'),
  ('14','26','Heady','43735666605','Commercial'),
  ('14','27','Piddletown','43735666603','Vendeur'),
  ('15','28','Heady','390676985610','Commercial'),
  ('15','29','Piddletown','0334237252','Vendeur'),
  ('16','30','Heady','390776985610','Accueil'),
  ('16','31','Piddletown','0334237252','Commercial'),
  ('17','32','Heady','390876985610','Commercial'),
  ('18','33','Heady','390576985610','Accueil'),
  ('19','34','Kirkwood','442076604454','Acheteur'),
  ('19','35','Benny','442076604455','Vendeur'),
  ('20','36','Forbes','442176604454','Accueil'),
  ('20','37','Easum','442176604455','Acheteur');
  
  

  
