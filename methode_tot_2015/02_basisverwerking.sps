* Encoding: windows-1252.

* locatie hoofdmap.
DEFINE basismap () 'G:\OD_IF_AUD\2_04_Statistiek\2_04_01_Data_en_kaarten\kadaster_percelen\kadaster_gebouwdelen_2015\' !ENDDEFINE.


* perceeldelen ophalen.
GET
  FILE=
    '' + basismap + 'legger\prc.sav'.
DATASET NAME prc WINDOW=FRONT.
dataset activate prc.

* koppelvelden aanmaken.
string AAV (a15).
compute AAV=concat(daa,"5",ord).
string art_deelnr (a15).
compute art_deelnr = concat(daa,"5",ord).

string da (a5).
compute da=char.substr(daa,1,5).

string #prc_clean  (a12).
compute #prc_clean=concat(char.substr(prc,1,5),"/",char.substr(prc,7)).
if length(rtrim(#prc_clean))=6 #prc_clean=concat(rtrim(#prc_clean),"00_").
if length(rtrim(#prc_clean))=8 #prc_clean=concat(rtrim(#prc_clean),"_").
compute #prc_clean=replace(#prc_clean," ","0").
compute #prc_clean=CHAR.RPAD(#prc_clean,12,"0").

string capakey (a17).
compute capakey=concat(da,#prc_clean).

* zie de syntax checken_capakey_da.sps om te helpen deze conversietabel te maken.
* dit is een ruwe benadering van een postcode.
compute #datemp=number(da,f5.0).
Recode #datemp
(11002=2000) (11003=2600) (11006=2140) (11012=2100)
(11014=2180) (11019=2660) (11028=2170) (11051=2610)
(11302=2600) (11303=2600) (11312=2140) (11313=2140)
(11342=2100) (11343=2100) (11344=2100) (11345=2100)
(11346=2100) (11363=2180) (11364=2180) (11382=2660)
(11383=2660) (11422=2170) (11423=2170) (11462=2610)
(11463=2610) (11802=2020) (11803=2000) (11804=2000)
(11805=2060) (11806=2060) (11807=2060) (11808=2018)
(11809=2020) (11810=2018) (11811=2000) (11812=2018)
(11813=2050) (11814=2030) (11815=2030) (11816=2030)
(11817=2030) (11818=2040) (11819=2040) (11820=2040)
(else=0)
INTO postcode_da.
execute.
alter type postcode_da (f4.0).


* gebiedsindeling ophalen (zie methode GIS).
GET
  FILE=
    '' + basismap + 'werkbestanden\sectoren_toekennen.sav'.
DATASET NAME statsec WINDOW=FRONT.
alter type capakey (a17).
alter type statsec (a4).
alter type WijkCode (a5).
sort cases capakey (a).

* gebiedsindeling koppelen aan perceeldelen.
dataset activate prc.
sort cases capakey (a).
MATCH FILES /FILE=*
  /TABLE='statsec'
  /BY capakey.
EXECUTE.

* checken op ontbrekende gevallen.
DATASET DECLARE test.
AGGREGATE
  /OUTFILE='test'
  /BREAK=capakey statsec WijkCode
  /N_BREAK=N.
dataset activate test.
frequencies statsec.
dataset activate prc.
dataset close test.
dataset close statsec.

* statistische sectoren kunnen ook redelijk goed naar postcodes omgezet worden.
* dit is iets zuiverder dan postcode_da, maar postcodes zijn veel te grillig om exact te benaderen op deze manier.
recode statsec
("C21-"=2060) ("R19-"=2100) ("P12-"=2180) ("U10-"=2610) ("Q11-"=2170) ("J881"=2030)
("C22-"=2060) ("R39-"=2100) ("P392"=2180) ("U11-"=2610) ("Q12-"=2170) ("J901"=2030)
("C23-"=2060) ("R101"=2100) ("T20-"=2600) ("E551"=2018) ("Q13-"=2170) ("J912"=2030)
("C41-"=2060) ("R12-"=2100) ("T21-"=2600) ("G51-"=2018) ("T10-"=2600) ("J923"=2030)
("H40-"=2060) ("R13-"=2100) ("T22-"=2600) ("G53-"=2018) ("T111"=2600) ("J932"=2030)
("H43-"=2060) ("R172"=2100) ("T23-"=2600) ("G54-"=2018) ("T12-"=2600) ("J94-"=2030)
("J072"=2000) ("R05-"=2100) ("T24-"=2600) ("G552"=2018) ("T13-"=2600) ("A04-"=2000)
("J83-"=2000) ("R180"=2100) ("T25-"=2600) ("G59-"=2018) ("T14-"=2600) ("A05-"=2000)
("S10-"=2140) ("R20-"=2100) ("D31-"=2018) ("F11-"=2020) ("T180"=2600) ("A10-"=2000)
("S11-"=2140) ("R21-"=2100) ("D34-"=2018) ("F12-"=2020) ("T19-"=2600) ("A12-"=2000)
("S12-"=2140) ("R22-"=2100) ("D35-"=2018) ("F60-"=2020) ("T412"=2600) ("A14-"=2000)
("S13-"=2140) ("R23-"=2100) ("D38-"=2018) ("F61-"=2020) ("T42-"=2600) ("A21-"=2000)
("S19-"=2140) ("R24-"=2100) ("D41-"=2018) ("F62-"=2020) ("Q03-"=2170) ("A22-"=2000)
("S28-"=2140) ("R28-"=2100) ("D42-"=2018) ("F64-"=2020) ("Q04-"=2170) ("E15-"=2000)
("S2MJ"=2140) ("R29-"=2100) ("K171"=2030) ("F65-"=2020) ("U30-"=2610) ("A00-"=2000)
("S41-"=2140) ("R30-"=2100) ("K172"=2030) ("U03-"=2610) ("U31-"=2610) ("A01-"=2000)
("S42-"=2140) ("R31-"=2100) ("K173"=2030) ("U40-"=2610) ("U32-"=2610) ("A02-"=2000)
("S43-"=2140) ("R32-"=2100) ("K174"=2030) ("U41-"=2610) ("U33-"=2610) ("A03-"=2000)
("S00-"=2140) ("R33-"=2100) ("K175"=2030) ("U43-"=2610) ("T00-"=2600) ("A081"=2000)
("S01-"=2140) ("R34-"=2100) ("K1MN"=2030) ("U47-"=2610) ("T01-"=2600) ("A11-"=2000)
("S02-"=2140) ("R35-"=2100) ("K271"=2040) ("U57-"=2610) ("T02-"=2600) ("A13-"=2000)
("S03-"=2140) ("R401"=2100) ("K272"=2040) ("U5MA"=2610) ("T03-"=2600) ("A15-"=2000)
("S04-"=2140) ("R41-"=2100) ("K2MN"=2040) ("U5PA"=2610) ("T04-"=2600) ("C42-"=2060)
("S05-"=2140) ("R42-"=2100) ("L070"=2040) ("U60-"=2610) ("T05-"=2600) ("C43-"=2060)
("S20-"=2140) ("R43-"=2100) ("L070"=2040) ("U68-"=2610) ("T09-"=2600) ("C44-"=2060)
("S30-"=2140) ("R44-"=2100) ("L17-"=2040) ("U69-"=2610) ("T30-"=2600) ("C45-"=2060)
("S31-"=2140) ("R47-"=2100) ("V00-"=2660) ("Q201"=2170) ("T39-"=2600) ("C491"=2060)
("E50-"=2018) ("R482"=2100) ("V01-"=2660) ("Q212"=2170) ("Q001"=2170) ("H41-"=2060)
("E521"=2018) ("C20-"=2018) ("V02-"=2660) ("Q222"=2170) ("Q012"=2170) ("H44-"=2060)
("E53-"=2018) ("C24-"=2018) ("V03-"=2660) ("Q2AA"=2170) ("Q021"=2170) ("F21-"=2020)
("G522"=2018) ("C25-"=2018) ("V04-"=2660) ("P33-"=2180) ("Q052"=2170) ("F223"=2020)
("U00-"=2610) ("C28-"=2018) ("V13-"=2660) ("P500"=2180) ("Q072"=2170) ("G72-"=2020)
("U01-"=2610) ("C29-"=2018) ("V20-"=2660) ("P589"=2180) ("Q091"=2170) ("G73-"=2020)
("U02-"=2610) ("C31-"=2018) ("V05-"=2660) ("P590"=2180) ("Q17-"=2170) ("G74-"=2020)
("U09-"=2610) ("D30-"=2018) ("V10-"=2660) ("P590"=2180) ("Q241"=2170) ("G75-"=2020)
("H4MJ"=2060) ("D32-"=2018) ("V11-"=2660) ("K214"=2040) ("Q242"=2170) ("G780"=2020)
("H83-"=2060) ("D33-"=2018) ("V12-"=2660) ("B701"=2050) ("Q49-"=2170) ("Q14-"=2170)
("H84-"=2060) ("P05-"=2180) ("V14-"=2660) ("B71-"=2050) ("E5MJ"=2000) ("Q233"=2170)
("H8MJ"=2060) ("P20-"=2180) ("V07-"=2660) ("B721"=2050) ("F6NJ"=2020) ("Q2PA"=2170)
("J820"=2000) ("P21-"=2180) ("V099"=2660) ("B73-"=2050) ("F6MJ"=2020) ("Q30-"=2170)
("J84-"=2000) ("P22-"=2180) ("V301"=2660) ("B742"=2050) ("L000"=2040) ("Q39-"=2170)
("J85-"=2000) ("P23-"=2180) ("V312"=2660) ("B752"=2050) ("L011"=2040) ("U20-"=2610)
("J873"=2000) ("P242"=2180) ("V322"=2660) ("B782"=2050) ("L022"=2040) ("U21-"=2610)
("R00-"=2100) ("P291"=2180) ("V373"=2660) ("B791"=2050) ("L090"=2040) ("U22-"=2610)
("R01-"=2100) ("P00-"=2180) ("V391"=2660) ("B813"=2050) ("L100"=2040) ("E122"=2000)
("R02-"=2100) ("P01-"=2180) ("V19-"=2660) ("B824"=2050) ("L111"=2040) ("E131"=2000)
("R03-"=2100) ("P02-"=2180) ("V21-"=2660) ("P100"=2180) ("L122"=2040) ("E14-"=2000)
("R04-"=2100) ("P03-"=2180) ("V22-"=2660) ("P111"=2180) ("L18-"=2040) ("E19-"=2000)
("R099"=2100) ("P04-"=2180) ("V23-"=2660) ("P192"=2180) ("J80-"=2030) 
("R110"=2100) ("P09-"=2180) ("V29-"=2660) ("Q10-"=2170) ("J81-"=2030) 
INTO postzone_statsec.
execute.

value labels postzone_statsec
2000 'Antwerpen centrum'
2018 'Antwerpen Zuid'
2020 'Antwerpen Kiel'
2030 'Haven'
2040 'Bezali'
2050 'Antwerpen Linkeroever'
2060 'Antwerpen Noord'
2100 'Deurne'
2140 'Borgerhout'
2170 'Merksem'
2180 'Ekeren'
2600 'Berchem'
2610 'Wilrijk'
2660 'Hoboken'.

SAVE OUTFILE='' + basismap + 'werkbestanden\basisbestand_gebouwdelen.sav'
  /COMPRESSED.




* KOPPELEN VAN PERCELEN EN EIGENAARS.

* art_nr of daa verenigt een clubje eigenaars.
* zo'n clubje kan uit 1 tot 4 eigenaars bestaan (in de datadump zoals we die krijgen).
* dit clubje kan vanalles in bezit hebben.
* we maken een bestand waarin elk perceeldeel (art_deelnr) even veel keer voorkomt als er eigenaars zijn.
* eerst maken we vier kopies van de perceeldelen. Bij de eerste kopie doen we alsof hier de eerste eigenaar uit het eigenaarsbestand hoort. Bij de tweede kopie enkel de tweede, enzovoorts.

* maak vier kopies van de perceeldelen.
DATASET ACTIVATE prc.
dataset copy match1.
DATASET ACTIVATE match1.
match files
/file=*
/keep=daa
sl1 postcode_da postzone_statsec capakey art_deelnr na1.
sort cases daa (a).
dataset copy match2.
dataset copy match3.
dataset copy match4.

* open de eigenaars en uniformiseer variabelen namen.
DATASET ACTIVATE eigenaars.
* dit kan je overslaan als je eigenaars nog open stonden.
GET
  FILE=
    '' + basismap + 'legger\pe.sav'.
DATASET NAME eigenaars WINDOW=FRONT.

*uniformiseer.
rename variables art_nr=daa.
rename variables pos=eigenaar_volgnummer.
sort cases daa (a).

* verdeel over vier bestanden volgens volgnummer van de eigenaar.
DATASET ACTIVATE eigenaars.
DATASET COPY  eigenaars1.
DATASET ACTIVATE  eigenaars1.
FILTER OFF.
USE ALL.
SELECT IF (eigenaar_volgnummer = 1).
EXECUTE.

DATASET ACTIVATE  eigenaars.
DATASET COPY  eigenaars2.
DATASET ACTIVATE  eigenaars2.
FILTER OFF.
USE ALL.
SELECT IF (eigenaar_volgnummer = 2).
EXECUTE.

DATASET ACTIVATE eigenaars.
DATASET COPY  eigenaars3.
DATASET ACTIVATE  eigenaars3.
FILTER OFF.
USE ALL.
SELECT IF (eigenaar_volgnummer = 3).
EXECUTE.

DATASET ACTIVATE eigenaars.
DATASET COPY  eigenaars4.
DATASET ACTIVATE  eigenaars4.
FILTER OFF.
USE ALL.
SELECT IF (eigenaar_volgnummer = 4).
EXECUTE.

* koppel de artikeldelen aan de eigenaars.
DATASET ACTIVATE match1.
MATCH FILES /FILE=*
  /TABLE='eigenaars1'
  /BY daa.
EXECUTE.
DATASET ACTIVATE match2.
MATCH FILES /FILE=*
  /TABLE='eigenaars2'
  /BY daa.
EXECUTE.
DATASET ACTIVATE match3.
MATCH FILES /FILE=*
  /TABLE='eigenaars3'
  /BY daa.
EXECUTE.
DATASET ACTIVATE match4.
MATCH FILES /FILE=*
  /TABLE='eigenaars4'
  /BY daa.
EXECUTE.

DATASET CLOSE eigenaars1.
DATASET CLOSE eigenaars2.
DATASET CLOSE eigenaars3.
DATASET CLOSE eigenaars4.

* voeg de artikeldelen weer samen.
DATASET ACTIVATE match1.
ADD FILES /FILE=*
  /FILE='match2'
  /FILE='match3'
  /FILE='match4'.
EXECUTE.
DATASET CLOSE match2.
DATASET CLOSE match3.
DATASET CLOSE match4.

* indien er minder dan vier eigenaars waren, hebben we lege extra rijen gecreeerd. Die halen we nu weer weg.
FILTER OFF.
USE ALL.
SELECT IF (eigenaar_volgnummer > 0).
EXECUTE.

* sluit het oorspronkelijke eigenaarsbestand.
dataset close eigenaars.

* geef het nieuwe eigenaarsbestand de roepnaam eigenaars.
dataset name eigenaars.

* soms is er één eigenaarscode die toch voor meerdere eigenaars wordt gebruikt.
* dit geeft soms problemen. Daarom passen we de eigenaarscode in die gevallen aan.
SORT CASES BY art_deelnr(A) Eig_code(A).
MATCH FILES
  /FILE=*
  /BY art_deelnr Eig_code
  /FIRST=PrimaryFirst
  /LAST=PrimaryLast.
DO IF (PrimaryFirst).
COMPUTE  MatchSequence=1-PrimaryLast.
ELSE.
COMPUTE  MatchSequence=MatchSequence+1.
END IF.
LEAVE  MatchSequence.
FORMATS  MatchSequence (f7).
COMPUTE  InDupGrp=MatchSequence>0.
SORT CASES InDupGrp(D).
FREQUENCIES VARIABLES=matchsequence.
EXECUTE.
* als er waarden groter dan 3 voorkomen, dan moet je de syntax aanpassen.
if matchsequence=2 eig_code=concat(ltrim(rtrim(eig_code)),"x").
if matchsequence=3 eig_code=concat(ltrim(rtrim(eig_code)),"y").
match files
/file=*
/drop=PrimaryFirst PrimaryLast MatchSequence InDupGrp.

* dit bestand hebben we de rest van dit script niet meer nodig.
 SAVE OUTFILE='' + basismap + 'werkbestanden\eigenaars_gebouwdeel.sav'
  /COMPRESSED.






* OPPERVLAKTE IN GIS OPHALEN.

* opmerking: de naam van dit bestand kan varieren van jaar tot jaar.
GET TRANSLATE
  FILE=
    '' + basismap +
    '\geometrie\Adp11002.dbf'
  /TYPE=DBF /MAP .
DATASET NAME gis WINDOW=FRONT.
match files
/file=*
/keep=capakey oppervl.
sort cases capakey (a).
rename variables oppervl=oppervlakte_perceel_gis.
alter type capakey (a17).
dataset activate prc.
*sort cases capakey (a).
MATCH FILES /FILE=*
  /TABLE='gis'
  /BY capakey.
EXECUTE.

dataset close gis.


* GEKOPPELDE WOONEENHEDEN OPHALEN.
* niet uitgevoerd omwille van kwaliteits-issues.


* EINDE KOPPELINGEN.



********************************


* BASISVERWERKING PERCEELDELEN.

* juridische oppervlakte.

recode co1 co2 (missing=0).
compute juridische_oppervlakte=co1+co2.
compute juridische_oppervlakte_belastbaar=co1.	
compute juridische_oppervlakte_onbelastbaar=co2.

AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES OVERWRITEVARS=YES
  /BREAK=capakey
  /juridische_oppervlakte_perceel=MAX(juridische_oppervlakte)
  /jur_opp_belastbaar_perceel=MAX(juridische_oppervlakte_belastbaar)			
  /jur_opp_onbelastbaar_perceel=MAX(juridische_oppervlakte_onbelastbaar).
DELETE VARIABLES juridische_oppervlakte.

* preprocessing van de constructiecode.
string CC_YN (a1).
recode cc (""="N") (else="Y") into CC_YN.
string CC_01 (a3).
string CC_02 (a1).
string CC_03 (a2).
string CC_04 (a1).
string CC_05 (a4).
string CC_06 (a2).
string CC_07 (a1).
string CC_08 (a3).
string CC_09 (a1).
string CC_10 (a3).
string CC_11 (a3).
string CC_12 (a4).
string CC_13 (a5).
string CC_14 (a5).
compute CC_01=char.substr(cc,1).
compute CC_02=char.substr(cc,4).
compute CC_03=char.substr(cc,5).
compute CC_04=char.substr(cc,7).
compute CC_05=char.substr(cc,8).
compute CC_06=char.substr(cc,12).
compute CC_07=char.substr(cc,14).
compute CC_08=char.substr(cc,15).
compute CC_09=char.substr(cc,18).
compute CC_10=char.substr(cc,19).
compute CC_11=char.substr(cc,22).
compute CC_12=char.substr(cc,25).
compute CC_13=char.substr(cc,29).
compute CC_14=char.substr(cc,34).

RECODE cc_yn ("Y"=1) ("N"=0) INTO cc_yn_num.
variable labels cc_yn_num 'heeft een classificatiecode of niet'.
variable labels CC_01 'Classificatiecode'.
variable labels CC_02 'Type van constructie'.
variable labels CC_03 'Aantal verdiepingen'.
variable labels CC_04 'Bewoonbare dakverdieping'.
variable labels CC_05 'Jaar beeindiging opbouw'.
variable labels CC_06 'jaar laatste fysische wijziging'.
variable labels CC_07 'kwaliteit van de constructie'.
variable labels CC_08 'aantal garages, parkings en/of overdekte standplaatsen'.
variable labels CC_09 'centrale verwarming'.
variable labels CC_10 'aantal badkamers'.
variable labels CC_11 'aantal zelfstandige woongelegenheden'.
variable labels CC_12 'aantal woonplaatsen'.
variable labels CC_13 'bebouwde grond oppervlakte'.
variable labels CC_14 'Nuttige oppervlakte'.


* CLASSIFICATIE SOORT PERCEEL.
* dit is een eigen eenvoudige classificatie.
* de basis-info is per perceeldeel. We gaan hier ook het perceeldeel in de context van zijn perceel bekijken, om complex gebruik in kaart te krijgen. 
* heel de module produceert enkel classificatie_eenvoudig, perceel_gebruik en app_lift. Al de andere variabelen zijn tussenvariabelen die achteraf gewist worden.
* de resulterende variabele is nagenoeg altijd inherent uniek op niveau van het perceel, enkel komt het vaak voor dat een deel van het gebruik onbekend is.

* maak cc_01 numeriek en voorzie van codeboek.
compute classificatiecode = number(cc_01,f3.0).
value labels classificatiecode
10 'Huis in een tuinwijk'
20 'Gekarakteriseerde hoeve'
30 'Villa'
31 'Bungalow'
32 'Fermette'
33 'Vakantieverblijf'
40 'Huis zonder bewoonbare kelder'
41 'Huis bel-etage'
50 'Huis met bewoonbare kelder'
60 'Huis met koetspoort als enige ingang'
70 'Huis met koetspoort en particuliere ingang'
80 'Huis zonder woonplaatsen op het gelijkvloers'
100 'appartementsgebouwen zonder lift Toebehorend aan een enkele eigenaar'
101 'appartementsgebouwen zonder lift Wooneenheid'
102 'appartementsgebouwen zonder lift Exploitatie-eenheid (voor beroeps-doeleinden, afzonderlijk gekadastreerd)'
103 'appartementsgebouwen zonder lift Garage, standplaats, parking, afzonderlijk gekadastreerd'
104 'appartementsgebouwen zonder lift Diverse lokalen (dienstbodenkamer, mansarde, kelder), afzonderlijk gekadastreerd'
105 'appartementsgebouwen zonder lift Huis#'
110 'appartementsgebouwen met lift Toebehorend aan een enkele eigenaar'
111 'appartementsgebouwen met lift Wooneenheid'
112 'appartementsgebouwen met lift Exploitatie-eenheid (voor beroeps-doeleinden, afzonderlijk gekadastreerd)'
113 'appartementsgebouwen met lift Garage, standplaats, parking, afzonderlijk gekadastreerd'
114 'appartementsgebouwen met lift Diverse lokalen (dienstbodenkamer, mansarde, kelder), afzonderlijk gekadastreerd'
200 'huizen met handelsbestemming  Zonder particuliere ingang'
210 'huizen met handelsbestemming  Met particuliere ingang'
220 'huizen met handelsbestemming  Met koetspoort alleen'
230 'huizen met handelsbestemming  Met koetspoort en particuliere ingang'
300 'Ambachten - Kleine ondernemingen - Nijverheid (Produktie van voedingswaren - Kleding en gebruiksartikelen - Bouwmaterialen - Andere produktiesektoren dan V tot VII - Diverse gebouwen en constructies'
305 'Ambachten - Kleine ondernemingen - Nijverheid (Produktie van voedingswaren - Kleding en gebruiksartikelen - Bouwmaterialen - Andere produktiesektoren dan V tot VII - Diverse gebouwen en constructies'
400 'Kantoorgebouwen'
410 'Gebouw bestemd voor handelsdoeinden (zonder woonfucntie)'
420 'Bedrijf uit de HORECA sector'
430 'Gebouw bestemd voor culturele, recreatieve of sportieve activiteiten'
440 'Gebouw bestemd voor sociale hulp of hospitalisatie'
450 'Gebouw bestemd voor het onderwijs'
460 'Gebouw bestemd voor de uitoefening van erediensten, enz'
470 'Kasteel'
480 'Openbaar gebouw of gebouw voor openbaar nut'
500 'Aanhorigheid van een woning (met uitzondering van bij een building behorende garages opgenomen onder de indicien 103 en 113)'
510 'Ambachtelijke- of industriele aanhorigheid'
520 'Aanhorigheid met handelsdoeleinden'
530 'Landbouwaanhorigheid'
531 'Serre behorende bij een landbouw, tuinbouw of wijngaarduitbating'
532 'Serre niet behorende bij een landbouw, tuinbouw of wijngaarduitbating (alleenstaande serre, door liefhebber uitgebate serre)'
540 'Gebouwen met bijzonder karakter'
999 '???'.
variable level classificatiecode (NOMINAL).

* maak een eenvoudige classificatie.
recode classificatiecode (10=1) (20=1) (30=1)
(31=1) (32=1) (33=1) (40=1) (41=1)
(50=1) (60=1) (70=1) (80=1)
(105=1) (100=2) (101=2) (110=2)
(111=2) (103=3) (104=3) (113=3)
(114=3) (102=4) (112=4) (200=5)
(210=5) (220=5) (230=5) (300=6)
(305=6) (410=5) (400=7) (420=8)
(430=9) (440=10) (450=11) (460=12)
(470=9) (540=9) (480=13) (500=14)
(510=14) (520=14) (530=14) (531=14)
(532=14) (999=15) into classificatie_eenvoudig.
VALUE LABELS classificatie_eenvoudig
1 'huizen'
2 'appartementen'
3 'aanhorigheden appartementen'
4 'handelseenheden'
5 'handelshuizen'
6 'industrieel pand'
7 'kantoor'
8 'horeca'
9 'cultuur en sport'
10 'gezondheid en sociaal'
11 'onderwijs'
12 'religie'
13 'overheid'
14 'andere aanhorigheid'
15 'anders/onbekend'
16 'geen classificatiecode'.
if missing(classificatie_eenvoudig) & cc_yn_num=0 classificatie_eenvoudig=16.



* dummy van gebruik.
if classificatiecode=10 huis=1.
if classificatiecode=20 huis=1.
if classificatiecode=30 huis=1.
if classificatiecode=31 huis=1.
if classificatiecode=33 huis=1.
if classificatiecode=40 huis=1.
if classificatiecode=41 huis=1.
if classificatiecode=50 huis=1.
if classificatiecode=60 huis=1.
if classificatiecode=70 huis=1.
if classificatiecode=80 huis=1.
if classificatiecode=105 huis=1.
if classificatiecode=100 appartement0=1.
if classificatiecode=101 appartement0=1.
if classificatiecode=110 appartement0=1.
if classificatiecode=111 appartement0=1.
if classificatiecode=103 aanhorigheid_appartement0=1.
if classificatiecode=104 aanhorigheid_appartement0=1.
if classificatiecode=113 aanhorigheid_appartement0=1.
if classificatiecode=114 aanhorigheid_appartement0=1.
if classificatiecode=102 handelseenheid0=1.
if classificatiecode=112 handelseenheid0=1.
if classificatiecode=200 handelshuis=1.
if classificatiecode=210 handelshuis=1.
if classificatiecode=220 handelshuis=1.
if classificatiecode=230 handelshuis=1.
if classificatiecode=300 industrieel_pand=1.
if classificatiecode=305 industrieel_pand=1.
if classificatiecode=410 handelshuis=1.
if classificatiecode=400 kantoor=1.
if classificatiecode=420 horeca=1.
if classificatiecode=430 cultuur_sport=1.
if classificatiecode=440 gezondheid_sociaal=1.
if classificatiecode=450 onderwijs=1.
if classificatiecode=460 religie=1.
if classificatiecode=470 cultuur_sport=1.
if classificatiecode=540 cultuur_sport=1.
if classificatiecode=480 overheid=1.
if classificatiecode=500 aanhorigheid_andere=1.
if classificatiecode=510 aanhorigheid_andere=1.
if classificatiecode=520 aanhorigheid_andere=1.
if classificatiecode=530 aanhorigheid_andere=1.
if classificatiecode=531 aanhorigheid_andere=1.
if classificatiecode=532 aanhorigheid_andere=1.
if classificatiecode=999 | missing(classificatiecode) onbekend0=1.
if classificatiecode=32 huis=1.

* drie soorten appartementen aanmaken.
AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=capakey
  /appartement0_max=max(appartement0) 
  /handelseenheid0_max=max(handelseenheid0).

recode appartement0_max
handelseenheid0_max (missing=0).

if appartement0_max=1 & handelseenheid0_max =0 woonappartement=1.
if appartement0_max=0 & handelseenheid0_max =1 handelsappartement=1.
if appartement0_max=1 & handelseenheid0_max =1 woonhandelsappartement=1.



AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=capakey
  /huis_max=MAX(huis) 
  /handelshuis_max=MAX(handelshuis) 
  /industrieel_pand_max=MAX(industrieel_pand) 
  /kantoor_max=MAX(kantoor) 
  /horeca_max=MAX(horeca) 
  /cultuur_sport_max=MAX(cultuur_sport) 
  /gezondheid_sociaal_max=MAX(gezondheid_sociaal) 
  /onderwijs_max=MAX(onderwijs) 
  /religie_max=MAX(religie) 
  /overheid_max=MAX(overheid) 
  /aanhorigheid_andere_max=MAX(aanhorigheid_andere) 
  /onbekend0_max=MAX(onbekend0).


if woonappartement=1 perceel_gebruik=2.
if handelsappartement=1 perceel_gebruik=3.
if woonhandelsappartement=1 perceel_gebruik=4.
if huis_max=1 perceel_gebruik=1.
if handelshuis_max=1 perceel_gebruik=5.
if industrieel_pand_max=1 perceel_gebruik=6.
if kantoor_max=1 perceel_gebruik=7.
if horeca_max=1 perceel_gebruik=8.
if cultuur_sport_max=1 perceel_gebruik=9.
if gezondheid_sociaal_max=1 perceel_gebruik=10.
if onderwijs_max=1 perceel_gebruik=11.
if religie_max=1 perceel_gebruik=12.
if overheid_max=1 perceel_gebruik=13.
if missing(perceel_gebruik) perceel_gebruik=14.

* er zijn maar twee geldige percelen met meer dan een gebruik, op deze manier gemeten.
* er zijn er wel veel met een bekend en een onbekend gebruik.

value labels perceel_gebruik
1 'huis'
2 'woonappartement'
3 'handelsappartement'
4 'woonhandelappartement'
5 'handelshuis'
6 'industrieel pand'
7 'kantoor'
8 'horeca'
9 'cultuur sport'
10 'gezondheid sociaal'
11 'onderwijs'
12 'religie'
13 'overheid'
14 'onbekend'.

EXECUTE.
delete variables huis
appartement0
aanhorigheid_appartement0
handelseenheid0
handelshuis
industrieel_pand
kantoor
horeca
cultuur_sport
gezondheid_sociaal
onderwijs
religie
overheid
aanhorigheid_andere
onbekend0
appartement0_max
handelseenheid0_max
woonappartement
handelsappartement
woonhandelsappartement
huis_max
handelshuis_max
industrieel_pand_max
kantoor_max
horeca_max
cultuur_sport_max
gezondheid_sociaal_max
onderwijs_max
religie_max
overheid_max
aanhorigheid_andere_max
onbekend0_max.


* wat heeft een lift en wat niet.
recode cc_01
('100'=0)
('101'=0)
('102'=0)
('103'=0)
('104'=0)
('105'=0)
('110'=1)
('111'=1)
('112'=1)
('113'=1)
('114'=1)
into app_lift.
variable labels app_lift "appartements met en zonder lift".
VALUE LABELS app_lift
0 'appartement zonder lift'
1 'appartement met lift'.
* opgelet: heel wat percelen omvatten zowel dingen met als zonder lift.

* einde verwerking cc_01.



* cc_02, type constructie.
* type bebouwing is niet enkel ingevuld voor panden waar wij dat als relevant zouden beschouwen.
recode cc_02 ('A'=1) ('B'=2) ('C'=3) into type_constructie.
VARIABLE LABELS type_constructie 'type constructie (open/halfopen/gesloten)'.
value labels type_constructie
1 'Gesloten bebouwing'
2 'Halfopen bebouwing'
3 'Open bebouwing'.



* VERDIEP EN AARD.

* cc_03, cc_04 EN sl2.
* cc_03 is een variable voor dingen met verdiepingen. Bijvoorbeeld een huis of een appartementsblok. Het gaat hier wel degelijk om verdiepen, niet over bouwlagen.
* sl2 gaat over waar op het perceel een perceeldeel lig. Dit bevat indien nodig de verdieping van het ding in kwestie. Bijvoorbeeld een appartement. 
* cc_04 gaat over bewoonde zolders.

* er zijn heel wat panden met nul verdiepen, maar slechts zelden is dit bij een type gebouw waar je dat niet zou verwachten.
* we maken een variabele die op gebouwniveau van toepassing is (n_verdiep) en een die op wooneenheden van toepassing is (verdiep).
* omdat gebouwen geen eenheid zijn, moeten we helaas aggregeren op perceel. We nemen dan het hoogste van de twee variabelen en tellen er eventueel nog de bewoonde zolders bij.

* hetzelfde perceel kan huizen en appartementen hebben, met elk een eigen aantal verdiepen.
* doorgaans heeft een perceel met appartementen een enkele record met het aantal verdiepen, de rest staat op missing.
* in Antwerpen bestaat een huis met 18 verdiepen :)

* enkel van "buildings" (een enkele eigenaar) worden verdiepen geregistreerd in de constructiecode, niet van woningen in een building .
* daarom is het nodig om ook het veld "sl2" (gedetailleerde ligging of iets dergelijks) te gebruiken.

compute n_verdiep = number(cc_03,f2.0).
if cc_03='' n_verdiep=9999.
if cc_03='--' n_verdiep=9998.
missing values n_verdiep (9999, 9998).
variable labels n_verdiep "aantal verdiepen cc03".


* sl2 bevat mogelijk zowel de "aard" als het verdiep.
* in theorie kan de aard enkel onderstaande dingen zijn.
string aard (a4).
if CHAR.INDEX(sl2,'#A')>0 aard=char.substr(sl2,char.index(sl2,'#A')+1,1).
if CHAR.INDEX(sl2,'#B')>0 aard=char.substr(sl2,char.index(sl2,'#B')+1,1).
if CHAR.INDEX(sl2,'#BU')>0 aard=char.substr(sl2,char.index(sl2,'#BU')+1,2).
if CHAR.INDEX(sl2,'#G')>0 aard=char.substr(sl2,char.index(sl2,'#G')+1,1).
if CHAR.INDEX(sl2,'#HA')>0 aard=char.substr(sl2,char.index(sl2,'#HA')+1,2).
if CHAR.INDEX(sl2,'#K')>0 aard=char.substr(sl2,char.index(sl2,'#K')+1,1).
if CHAR.INDEX(sl2,'#KA')>0 aard=char.substr(sl2,char.index(sl2,'#KA')+1,2).
if CHAR.INDEX(sl2,'#M')>0 aard=char.substr(sl2,char.index(sl2,'#M')+1,1).
if CHAR.INDEX(sl2,'#P')>0 aard=char.substr(sl2,char.index(sl2,'#P')+1,1).
if CHAR.INDEX(sl2,'#S')>0 aard=char.substr(sl2,char.index(sl2,'#S')+1,1).
if CHAR.INDEX(sl2,'#T')>0 aard=char.substr(sl2,char.index(sl2,'#T')+1,1).
if CHAR.INDEX(sl2,'#VITR')>0 aard=char.substr(sl2,char.index(sl2,'#VITR')+1,4).

* in theorie volgt onmiddelijk op aard de verdieping.
string verdiep0 (a254).
if aard~="" verdiep0=char.substr(sl2,length(ltrim(rtrim(aard)))+4).
* normaal gezien volgt op het verdiep een slash of niets meer.
string verdiep1 (a254).
compute verdiep1=char.substr(verdiep0,1,CHAR.INDEX(verdiep0,"/")-1).
do if CHAR.INDEX(verdiep0,"/")=0.
compute verdiep1=char.substr(verdiep0,1).
end if.

* maar soms hangen er nog spaties of punten voor het verdiep begint.
compute verdiep1=ltrim(ltrim(verdiep1,".")).

* soms staat er een punt in het verdiep.
if CHAR.INDEX(verdiep1,".")>0 verdiep1=char.substr(verdiep1,1,CHAR.INDEX(verdiep1,".")-1).
* of een liggend streepje.
* in beide gevallen gaan we ervan uit dat het verdiep dan omschreven staat vOOr dat punt of streepje.
* OPMERKING: soms staat er iets als 1.2.3; dit wijzen we toe als 1. Wellicht zou 3 beter zijn. Misschien ook niet. 
* Alleszins is het wat complexer om die drie op te pikken zonder andere problemen te introduceren.
if CHAR.INDEX(verdiep1,"-")>0 verdiep1=char.substr(verdiep1,1,CHAR.INDEX(verdiep1,"-")-1).
if CHAR.INDEX(verdiep1," ")>0 verdiep1=char.substr(verdiep1,1,CHAR.INDEX(verdiep1," ")-1).
if CHAR.INDEX(verdiep1,"@")>0 verdiep1=char.substr(verdiep1,1,CHAR.INDEX(verdiep1,"@")-1).
if CHAR.INDEX(verdiep1,"&")>0 verdiep1=char.substr(verdiep1,1,CHAR.INDEX(verdiep1,"&")-1).
* we gaan ervan uit dat als het verdiepnummer nu nog altijd begint met OG, GV, TV of BE, alles wat erachter komt weg mag.
if CHAR.INDEX(verdiep1,"GV")=1 verdiep1=char.substr(verdiep1,1,2).
if CHAR.INDEX(verdiep1,"OG")=1  verdiep1=char.substr(verdiep1,1,2).
if CHAR.INDEX(verdiep1,"TV")=1 verdiep1=char.substr(verdiep1,1,2).

* we zetten het om naar een numerieke waarde.
compute verdiep=number(verdiep1,f3.0).
recode verdiep1 ('GV'=0) ('OG'=-1) ('TV'=0.5) ('BE'=0.75) into verdiep.
* opmerking: gv=gelijkvloers, og=ondergronds, er kunnen eventueel meerdere verdiepen of lokalen zijn, 
TV=tussenverdiep, 'BE'=bel-etage.


* indien S, G, K, P, B  dan is het een nummer, geen verdiep.
* indien VITR dan is het nog iets anders.
if aard="S" | aard="G" | aard="K" | aard="P" | aard="B" | aard="VITR" verdiep=$sysmis.

* enkele records hebben een belachelijk hoog aantal verdiepingen.
if verdiep>40 verdiep=$sysmis.

* einde toewijzing verdiep per rij. 
* we aggregeren per perceel om het aantal verdiepen van gebouwen te benaderen.

* opkuisen aard.
rename variables aard=aard0.
recode aard0 
('A'=1)
('B'=2)
('BU'=3)
('G'=4)
('HA'=5)
('K'=6)
('KA'=7)
('M'=8)
('P'=9)
('S'=10)
('T'=11)
('VITR'=12)
into aard.
value labels aard
1 'wooneenheid'
2 'bergplaats'
3 'bureaus'
4 'garage'
5 'handel'
6 'kelder'
7 'kamer'
8 'zolderkamer'
9 'parking'
10 'standplaats'
11 'tuin'
12 'vitrine'.
execute.
delete variables verdiep0 verdiep1  aard0.
* opmerking: enkele rijen krijgen een foute 'aard', omdat bijvoorbeeld BOUWGROND in dit veld gebruikt wordt, wat volgens de documentatie niet kan.

recode verdiep (missing=9999).
missing values verdiep (9999).

* cc_04, is er een zolder.
* die nemen we mee in sommige verdiepentellers.
recode cc_04 (''=9999) ('-'=9998) ('N'=0) ('Y'=1) into bewoonbare_dakverdieping.
missing values bewoonbare_dakverdieping (9999, 9998).
VARIABLE LABELS bewoonbare_dakverdieping "bewoonbare dakverdieping (cc_04)".


* variabele om de 'beste' verdiepschatting te maken per perceel.
* OPMERKING: niet echt logisch dat dit hier staat.
AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=capakey
  /n_verdiep_max=MAX(n_verdiep) 
  /verdiep_max=MAX(verdiep)
  /dakverdiep_max=max(bewoonbare_dakverdieping).

compute verdiepen_perceel=max(n_verdiep_max,verdiep_max).
if missing(verdiepen_perceel) verdiepen_perceel=n_verdiep_max.
if missing(verdiepen_perceel) verdiepen_perceel=verdiep_max.
compute verdiepen_perceel=trunc(verdiepen_perceel).
compute verdiepen_inc_dakverdiep=verdiepen_perceel.
if dakverdiep_max=1 verdiepen_inc_dakverdiep=verdiepen_perceel+1.
EXECUTE.
delete variables n_verdiep_max verdiep_max dakverdiep_max.

variable labels verdiep "hoeveelste verdiep (sl2)".
variable labels verdiepen_perceel "aantal verdiepen perceel (sl2 en cc_03)".
variable labels verdiepen_inc_dakverdiep "aantal verdiepen perceel (inclusief dakverdiep)".





* cc_05, bouwjaar.
* tot 1930 is dit een categorie, daarna is het een exact cijfer.
* opnieuw: verschillende perceeldelen kunnen verschillende bouwjaren hebben. 
* In Antwerpen is dit in ongeveer  1200-1500 van de 140000 percelen het geval.
* 10% percelen zonder bouwjaar.


compute bouwjaar_ruw=number(cc_05,f4.0).
recode bouwjaar_ruw (1 thru 5 = copy) (6 thru highest=6) (missing=99) into bouwjaar_cat.
if bouwjaar_ruw>1930 & bouwjaar_ruw <1946 bouwjaar_cat=6.
if bouwjaar_ruw>1945 & bouwjaar_ruw <1983 bouwjaar_cat=7.
if bouwjaar_ruw>1983 & bouwjaar_ruw <1999 bouwjaar_cat=8.
if bouwjaar_ruw>1999 bouwjaar_cat=9.
value labels bouwjaar_cat
1  "voor 1850"
2 "1850-1874"
3 "1875-1899"
4 "1900-1918"
5 "1919-1930"
6 "1930-1945"
7 "1946-1983"
8 "1984-1999"
9 "2000-nu"
99 "leeg".
missing values bouwjaar_cat (99).

recode bouwjaar_ruw
(0 =99) (1=1800) (2=1862) (3=1887) (4=1908) (5=1924) (6 thru highest=copy) (missing=99)
into bouwjaar_schatting.
missing values bouwjaar_schatting (99).

if bouwjaar_ruw > 1930 bouwjaar_exact=bouwjaar_ruw.

variable labels bouwjaar_ruw "bouwjaar (categorie en jaar door elkaar)".
variable labels bouwjaar_cat "bouwjaar (categorie, alle percelen)".
variable labels bouwjaar_schatting "bouwjaar (schatting waar categorie, exact waar beschikbaar)".
variable labels bouwjaar_exact "bouwjaar (enkel indien exact)".




*cc_06, "renovatiejaar".
* dit is de laatste maal dat een wijziging op dit perceel aan het kadaster werd gemeld.
* het kan dan gaan om en verbouwingsplichtige renovatie, een wijziging van het aantal wooneenheden, etc.
* millenium bug: slechts twee digits beschikbaar. Maar sowieso pas ingevuld vanaf 1982, dus het probleem stelt zich pas in 2082.
compute jaar_wijziging=number(cc_06,f2.0).
if jaar_wijziging <82 jaar_wijziging=2000+jaar_wijziging.
if jaar_wijziging<100 jaar_wijziging=1900+jaar_wijziging.
alter type jaar_wijziging (f4.0).

recode jaar_wijziging (1982 thru 1990 = 1) (1991 thru 1999=2) (2000 thru 2006=3) (2007 thru highest=4) into jaar_wijziging_cat.
value labels jaar_wijziging_cat
1 '1982-1990'
2 '1991-1999'
3 '2000-2006'
4 '2007-heden'.




* cc_07, "kwaliteit van de constructie".
* opmerking: 98,8% van de valid cases zijn "normaal".
* dit is in verhouding tot de buurt en het type pand. Een villa in een villawijk is dus normaal.
recode cc_07 ("M"=1) ("N"=2) ("L"=3) ("-"=98) (""=99) into kwaliteit.
missing values kwaliteit (98,99).
value labels kwaliteit
1 'minderwaardig'
2 'normaal'
3 'luxueus'.



* cc_08, "garages, parkings en/of overdekte standplaatsen".
* deze informatie zit verspreid over drie velden: sl2, classficatiecode, cc_08.
compute aantal_garages_ed_cc_08=number(cc_08,f3.0).
alter type aantal_garages_ed_cc_08 (f3.0).

* op basis van sl2 weten we het soort parkeerplaats.
if aard=4 | aard= 9 | aard=10 aard_parkeren=1.
if aard=4 aard_garage=1.
if aard=10 aard_standplaats=1.
if aard=9 aard_parking=1.
* in de classificatiecode kunnen we ook parkeerplaatsen vinden.
if classificatiecode=103 | classificatiecode=113 classificatie_parkeren=1.

* er zijn dus drie bronnen om een rij als een ding met een parkeerplaats te beschouwen.
if aantal_garages_ed_cc_08>0 | classificatie_parkeren=1 | aard_parkeren=1 ding_met_parking=1.

* sommige records hebben een aantal plaatsen, andere ZIJN een plaats. dus een complexe teller bouwen die het beste verzamelt.
* er zijn geen percelen waar zowel het aantal is ingevuld als dat er records zijn met individuele plaatsen.
compute aantal_parkeerplaatsen=0.
if aantal_garages_ed_cc_08>0 aantal_parkeerplaatsen=aantal_garages_ed_cc_08.
if aard_parkeren=1 & aantal_parkeerplaatsen=0 aantal_parkeerplaatsen=1.
if classificatie_parkeren=1 & missing(aard) & aantal_parkeerplaatsen=0 aantal_parkeerplaatsen=1.

* wat voor parkeerplaats is het?.
* indien geen details, zeg 1 of het aantal gekende plaatsen.
if (missing(aard_garage) & missing(aard_parking) & missing(aard_standplaats)) parking_onbekend_type=aantal_garages_ed_cc_08.
if classificatie_parkeren=1 & missing(aard_garage) & missing(aard_parking) & missing(aard_standplaats) & (missing(aantal_garages_ed_cc_08) | aantal_garages_ed_cc_08=0) parking_onbekend_type=1.
* indien wel details, zeg 1 of het aantal plaatsen.
if aantal_garages_ed_cc_08>0 & aard_garage=1 aard_garage=aantal_garages_ed_cc_08.
if aantal_garages_ed_cc_08>0 & aard_standplaats=1 aard_standplaats=aantal_garages_ed_cc_08.
if aantal_garages_ed_cc_08>0 & aard_parking=1 aard_parking=aantal_garages_ed_cc_08.

variable labels aantal_parkeerplaatsen "parkeergelegenheden (cc_08+cc01+sl2)".
variable labels aard_parkeren "parkeergelegenheden (sl2+cc08)".
variable labels aard_garage "garages (sl2+cc08)".
variable labels aard_standplaats "standplaats (sl2+cc08)".
variable labels aard_parking "parking (sl2+cc08)".
variable labels parking_onbekend_type "andere parkeerplaatsen (cc01+cc08)".

EXECUTE.
delete variables ding_met_parking aard_parkeren aantal_garages_ed_cc_08 classificatie_parkeren.



* cc09, centrale verwarming.
recode cc_09 ("Y"=1) ("N"=0) ("-"=98) (else=99) into centrale_verwarming.
missing values centrale_verwarming (99,98).


* cc_10, aantal badkamers.
compute aantal_badkamers=number(cc_10,f3.0).



* woningen tellen.

*VOORBEREIDING.

* een van de moeilijkste onderdelen van dit werk.
* onderstaande methode is het resultaat van uitgebreide vergelijkingen met de census, bevolkingsstatistieken en case studies.
* maar ze zit niet geweldig logisch in elkaar.

*CC_11 'aantal zelfstandige woongelegenheden'.
compute aantal_woningen_cc11=number(cc_11,f3.0).

* appartementen, appartementsgebouwen en huizen hebben sowieso minstens 1 woning.
recode cc_01 ('010'=1) ('020'=1) ('030'=1) ('031'=1) ('032'=1) ('033'=1) ('040'=1) 
('041'=1) ('050'=1) ('060'=1) ('070'=1) ('080'=1) ('100'=1) ('101'=1) ('105'=1) ('110'=1) ('111'=1)
into cc01_woontype.

* aard, afgeleide van sl2.
if aard=1 woning_aard=1.
recode woning_aard (missing=0).

* perceel gebruik: : 
classificatie van het gebruik van het perceel, op basis van aggregatie van cc01. Puur een vereenvoudiging van cc01, behalve voor woonhandelsappartementen
1-4: huizen, appartementen (inclsuief handel)
5: handelshuizen
14: onbekend
perceel_gebruik.

recode cc01_woontype woning_aard aantal_woningen_cc11 (missing=0).


* UITVOERING.

* voor percelen met huizen of appartementen
    EN het ding zelf is een woontype cc01  OF het heeft een woning aard (volgens sl2)
    EN er is een woningenteller (in cc11)
    TEL die woningenteller.

if perceel_gebruik<5 & (cc01_woontype=1 | woning_aard=1) woningen=aantal_woningen_cc11.
* opmerking: er zijn 2000 records zonder woningenteller die hier niet meegenomen worden. Verder onderzoek zou kunnen uitwijzen dat je die best toch meeneemt.

* handelshuizen tellen we mee als er een woningenteller is ingevuld.
if perceel_gebruik=5 woningen=aantal_woningen_cc11.

* percelen met een ander gekend type gebruik tellen we nooit als woning.
if perceel_gebruik>5 & perceel_gebruik<14 woningen=0.

* indien het gebruik van het perceel onbekend is, dan tellen we ze als één woning als het een woning aard heeft, of volgens de teller van het aantal woningen als deze ingevuld is (ook als het geen woning aard heeft).
if perceel_gebruik=14 & woning_aard=1 woningen=max(1,aantal_woningen_cc11).
if perceel_gebruik=14 & woning_aard=0 woningen=aantal_woningen_cc11.


* bij aggregeren gewoon de som nemen.
recode woningen (missing=0).

* einde woningen tellen.




* woonplaatsen of kamers.
* ook ingevuld voor andere dingen dan wooneenheden.
* indien enkel volgens sl2 een woning: 81% missings.

variable labels CC_12 'aantal woonplaatsen (kamers)'.

if woningen>0 aantal_kamers=number(cc_12,f4.0).
recode aantal_kamers  (missing=0).
compute kamers_per_woning=aantal_kamers/woningen.
* extreme waarden verwijderen.
recode kamers_per_woning (0=sysmis) (31 thru highest=sysmis).
* indien extreme waarde, ook de teller zelf verwijderen.
if missing(kamers_per_woning) aantal_kamers=$sysmis.
* teller voor kamers in andere dingen dan woningen.
if woningen=0 & number(cc_12,f4.0)>0 kamers_niet_woning = number(cc_12,f4.0).

variable labels kamers_per_woning 'kamers per woning'.
variable labels aantal_kamers 'kamers in woningen'.
variable labels kamers_niet_woning 'kamers in andere dingen dan woningen'.




* bebouwde oppervlakte.

variable labels CC_13 'bebouwde grondoppervlakte'.
compute bebouwde_oppervlakte_origineel=number(cc_13,f5.0).
* slechts 40 percelen met meer dan een oppervlaktewaarde.
* bijna 20% missings op perceelniveau.
* ontbreekt vaak als er woningen zijn.
* bebouwde oppervlakte ontbreekt bij percelen die ingedeeld zijn in appartementen met meerdere eigenaars.


* nuttige oppervlakte.
variable labels CC_14 'Nuttige oppervlakte'.
compute nuttige_oppervlakte_origineel=number(cc_14,f5.0).
* nagenoeg voor alle woningen ingevuld.
* van de woning-rijen heeft 52%  zowel nuttige als bebouwde oppervlakte.


* cleanen oppervlaktes.

* indien je wil zien welke percelen een rare geometrie of een rare wettelijke oppervlakte hebben.
* compute test_gis_jur=juridische_oppervlakte_perceel/oppervlakte_perceel_gis.

* arbitraire grens: indien de bebouwde oppervlakte meer dan dubbel zo groot is als het maximum van geografische 
of juridsiche oppervlakte, dan beschouwen we deze als fout (onbestaand).
compute #test_bebouwde_opp=bebouwde_oppervlakte_origineel/max(oppervlakte_perceel_gis,juridische_oppervlakte_perceel).
if #test_bebouwde_opp<2 bebouwde_oppervlakte=bebouwde_oppervlakte_origineel.

* arbitraire grens: indien de nuttige oppervlakte meer dan dubbel zo groot is als het maximum van geografische of juridsiche oppervlakte, vermenigvuldigd met het aantal bouwlagen, dan beschouwen we deze als fout (onbestaand).
* we passen dit enkel toe indien er minstens een verdiepen is.
recode verdiepen_inc_dakverdiep
(lowest thru 0=0) (0 thru 0.99=0) (missing=0) into #verdiepenteller.
compute #test_nuttige_opp=nuttige_oppervlakte_origineel/(max(oppervlakte_perceel_gis,juridische_oppervlakte_perceel)*(#verdiepenteller+1)).
if #test_nuttige_opp< 2 | #verdiepenteller=0 nuttige_oppervlakte=nuttige_oppervlakte_origineel.

* als je alle rare gevallen bovenaan wilt hebben (best in hele module # verwijderen).
*compute maxtest=max(test_bebouwde_opp,test_nuttige_opp,test_gis_jur).
*sort cases maxtest (d).

* einde oppervlakte cleaning




* waar zijn de kelders.
if classificatiecode=104 | classificatiecode=114 | aard=6 kelder=1.


* EINDE UNIVERSELE VERWERKING.

* indeling die NIScodes voor grondgebruik probeert te reconstrueren.
* toewijzing aangeleverd door Virge.

* TECHNISCH: opgelet met tekstvariabelen: soms gaat SPSS lege tekst als spaties beschouwen. Dus als je zes tekens hebt, zal die enkel "grond " herkennen als geldig, niet "grond".

* OPMERKINGEN:
* er zijn wel wat percelen met meerdere "functies".
* maar in bijna alle gevallen is er een "functie" die je kan negeren, bijvoorbeeld "grond".
* we sorteren zo dat de eerste functie wellicht de meest zinvolle is, die nemen we dan mee in de aggregatie.
* > deze oplossing wordt hier niet toegepast, omdat we de classificatiecode gebruiken om het perceel te kwalificeren. de info hier gebruiken we enkel op niveau van de gebouwdelen.
rename variables na1=art_aard.
recode art_aard 
('BEB.OPP.A'=1)
('BUILDING'=1)
('D.AP.GEB.#'=1)
('G.D.AP.GEB'=1)
('M.D.AP.GEB'=1)
('OPP.& G.D.'=1)
('AFDAK'=2)
('AFDAK          '=2)
('BERGPLAATS'=2)
('DUIVENTIL'=2)
('G.VEETEELT'=2)
('GARAGE'=2)
('HOEVE'=2)
('HUIS'=2)
('HUIS#'=2)
('K.VEETEELT'=2)
('KROTWONING'=2)
('LANDGEBOUW'=2)
('LAVATORY'=2)
('NOODWONING'=2)
('PAARDESTAL'=2)
('PADDEST/KW'=2)
('SERRE'=2)
('AARDEW/FAB'=3)
('BAKKERIJ'=3)
('BOUWMAT/F.'=3)
('BROUWERIJ'=3)
('CEMENTFAB.'=3)
('CHEMIC/FAB'=3)
('COKESFABR.'=3)
('CONSTR/WPL'=3)
('DRANKFABR.'=3)
('DROOGINST.'=3)
('DRUKKERIJ'=3)
('ELEK.CENTR'=3)
('ELEK.MAT.F.'=3)
('GAR.WERKPL'=3)
('GASFABRIEK'=3)
('GAZOMETER'=3)
('GEBRUIKS/F'=3)
('GLASFABR.'=3)
('HOOGOVEN'=3)
('IJSFABRIEK'=3)
('KALKHOVEN'=3)
('KLEDINGFAB'=3)
('KOELINR.'=3)
('KOFFIEFAB.'=3)
('KOLENMIJN'=3)
('LEDERWAR/F'=3)
('MAALDERIJ'=3)
('MAT. & OUT.'=3)
('METAALNIJV'=3)
('MEUBELFAB.'=3)
('NIJV/GEB.'=3)
('PAPIERFAB.'=3)
('PETROL/RAF'=3)
('PLAST/FAB.'=3)
('RESERVOIR'=3)
('RUBBERFAB.'=3)
('SCHRIJNW.'=3)
('SILO'=3)
('SLACHTERIJ'=3)
('SMIDSE'=3)
('SPEELG/FAB'=3)
('STEENBAKK.'=3)
('TABAKFABR.'=3)
('TEXTIELFAB'=3)
('VEEVOE/FAB'=3)
('VERFFABR.'=3)
('VLEESW/FAB'=3)
('VOEDINGS/F'=3)
('WASSERIJ'=3)
('WERKPLAATS'=3)
('ZAGERIJ'=3)
('ZUIVELFAB.'=3)
('HANGAR'=4)
('MAGAZIJN'=4)
('BANK'=5)
('BEURS'=5)
('KANTOORGEB'=5)
('DIERENGEB.'=6)
('DRANKHUIS'=6)
('GAR.STELPL'=6)
('GR.WARENH.'=6)
('HAND/HUIS'=6)
('HOTEL'=6)
('KIOSK'=6)
('OVER.MARKT'=6)
('PARKEERGEB'=6)
('RESTAURANT'=6)
('SERV.STAT.'=6)
('TOONZAAL'=6)
('ADMIN.GEB.'=7)
('AFVALVERW.'=7)
('BADINRICHT'=7)
('BESCHER/W.'=7)
('BIBLIOTH.'=7)
('BIOSCOOP'=7)
('BISDOM'=7)
('CABINE'=7)
('CASINO'=7)
('ELEK.CABIN'=7)
('FEESTZAAL'=7)
('GASCABINE'=7)
('GEB.ERED.'=7)
('GEM/HUIS'=7)
('GENDARMER.'=7)
('GERECHTSH.'=7)
('GEZANTSCH.'=7)
('GOUVER/GEB'=7)
('HISTOR.GEB'=7)
('JEUGDHEEM'=7)
('K.PALEIS'=7)
('KAPEL'=7)
('KASTEEL'=7)
('KERK'=7)
('KINDERBEW.'=7)
('KLOOSTER'=7)
('KULT.CENTR'=7)
('KUURINR.'=7)
('LIJKENHUIS'=7)
('LUCHTHAVEN'=7)
('MILIT.GEB.'=7)
('MONUMENT'=7)
('MOSKEE'=7)
('MUSEUM'=7)
('ONDERGR. R.'=7)
('ONDERZOEKC'=7)
('PASTORIE'=7)
('PAVILJOEN'=7)
('PUIN'=7)
('PYLOON'=7)
('RUSTHUIS'=7)
('SCHOOLGEB.'=7)
('SEMINARIE'=7)
('SPEKT/ZAAL'=7)
('SPORTGEB.'=7)
('STATION'=7)
('STRAFINR.'=7)
('SYNAGOGE'=7)
('TEL/CEL'=7)
('TELECOM/G.'=7)
('TEMPEL'=7)
('THEATER'=7)
('UNIVERSIT.'=7)
('VAKAN/TEH.'=7)
('VAKAN/VERB'=7)
('VERPL/INR.'=7)
('WACHTHUIS'=7)
('WATERMOLEN'=7)
('WATERTOREN'=7)
('WATERWINN.'=7)
('WEESHUIS'=7)
('WELZIJNSG.'=7)
('WINDMOLEN'=7)
('ZUIVER/INS'=7)
('AANSPOEL.'=8)
('BASSIN GEW'=8)
('BEB.OPP.G'=8)
('BEB.OPP.N'=8)
('BEB.OPP.U'=8)
('BOOMG.HOOG'=8)
('BOOMG.LAAG'=8)
('BOOMKWEK.'=8)
('BOS'=8)
('BOUWGROND'=8)
('BOUWLAND'=8)
('D.PARKING#'=8)
('DIJK'=8)
('GRACHT'=8)
('HEIDE'=8)
('HOOILAND'=8)
('KAAI'=8)
('KAMPEERT.'=8)
('KANAAL'=8)
('KERKHOF'=8)
('KOER'=8)
('MEER'=8)
('MILIT.TERR'=8)
('MOERAS'=8)
('NIJV/GROND'=8)
('PARK'=8)
('PARKING'=8)
('PLEIN'=8)
('POEL'=8)
('SLOOT'=8)
('SPEELTERR.'=8)
('SPOORWEG'=8)
('SPORTTERR.'=8)
('STORT.WGR.'=8)
('TUIN'=8)
('VIJVER'=8)
('VLIEGVELD'=8)
('WAL'=8)
('WARMOESGR.'=8)
('WEG'=8)
('WEILAND'=8)
('WERF'=8)
('WOESTE GR.'=8)
('BEDRIJFSC#'=9)
('GROND'=9)
('MAT.& OUT.'=9)
('UITKIJK'=9) into NIS_hoofdgroep.
value labels nis_hoofdgroep
1 '1. Appartementen en buildings'
2 '2. Huizen en hoeven en bijgebouwen'
3 '3. Industriele gebouwen'
4 '4. Opslaggebouwen'
5 '5. Kantoorgebouwen'
6 '6. Commerciele gebouwen'
7 '7. Andere'
8 'Onbebouwde percelen'
9 'Andere'.

recode art_aard
('D.AP.GEB.#'=1)
('M.D.AP.GEB'=1)
('DIERENGEB.'=2)
('GAR.STELPL'=2)
('GR.WARENH.'=2)
('HAND/HUIS'=2)
('KIOSK'=2)
('OVER.MARKT'=2)
('PARKEERGEB'=2)
('SERV.STAT.'=2)
('TOONZAAL'=2)
('AARDEW/FAB'=3)
('BAKKERIJ'=3)
('BOUWMAT/F.'=3)
('BROUWERIJ'=3)
('CEMENTFAB.'=3)
('CHEMIC/FAB'=3)
('COKESFABR.'=3)
('CONSTR/WPL'=3)
('DRANKFABR.'=3)
('DROOGINST.'=3)
('DRUKKERIJ'=3)
('ELEK.CENTR'=3)
('ELEK.MAT.F.'=3)
('GAR.WERKPL'=3)
('GASFABRIEK'=3)
('GAZOMETER'=3)
('GEBRUIKS/F'=3)
('GLASFABR.'=3)
('HOOGOVEN'=3)
('IJSFABRIEK'=3)
('KALKHOVEN'=3)
('KLEDINGFAB'=3)
('KOELINR.'=3)
('KOFFIEFAB.'=3)
('KOLENMIJN'=3)
('LEDERWAR/F'=3)
('MAALDERIJ'=3)
('MAT. & OUT.'=3)
('METAALNIJV'=3)
('MEUBELFAB.'=3)
('NIJV/GEB.'=3)
('PAPIERFAB.'=3)
('PETROL/RAF'=3)
('PLAST/FAB.'=3)
('RESERVOIR'=3)
('RUBBERFAB.'=3)
('SCHRIJNW.'=3)
('SILO'=3)
('SLACHTERIJ'=3)
('SMIDSE'=3)
('SPEELG/FAB'=3)
('STEENBAKK.'=3)
('TABAKFABR.'=3)
('TEXTIELFAB'=3)
('VEEVOE/FAB'=3)
('VERFFABR.'=3)
('VLEESW/FAB'=3)
('VOEDINGS/F'=3)
('WASSERIJ'=3)
('WERKPLAATS'=3)
('ZAGERIJ'=3)
('ZUIVELFAB.'=3)
('D.PARKING#'=4)
('KERKHOF'=4)
('KOER'=4)
('MILIT.TERR'=4)
('ONDERGR. R.'=4)
('PARKING'=4)
('VLIEGVELD'=4)
('BANK'=5)
('BEURS'=5)
('KANTOORGEB'=5)
('AFDAK          '=6)
('BERGPLAATS'=6)
('GARAGE'=6)
('LAVATORY'=6)
('BOOMG.HOOG'=7)
('BOOMG.LAAG'=7)
('BOS'=8)
('BOUWLAND'=9)
('BOUWGROND'=10)
('BUILDING'=11)
('BISDOM'=12)
('GEB.ERED.'=12)
('KAPEL'=12)
('KERK'=12)
('KLOOSTER'=12)
('MOSKEE'=12)
('PASTORIE'=12)
('SEMINARIE'=12)
('SYNAGOGE'=12)
('TEMPEL'=12)
('BEB.OPP.A'=13)
('G.D.AP.GEB'=13)
('OPP.& G.D.'=13)
('BASSIN GEW'=14)
('GRACHT'=14)
('KANAAL'=14)
('MEER'=14)
('POEL'=14)
('SLOOT'=14)
('VIJVER'=14)
('PLEIN'=15)
('WEG'=15)
('HOOILAND'=16)
('DRANKHUIS'=17)
('HOTEL'=17)
('RESTAURANT'=17)
('HOEVE'=18)
('HUIS'=18)
('HUIS#'=18)
('KROTWONING'=18)
('NOODWONING'=18)
('DUIVENTIL'=19)
('G.VEETEELT'=19)
('K.VEETEELT'=19)
('LANDGEBOUW'=19)
('PAARDESTAL'=19)
('PADDEST/KW'=19)
('HISTOR.GEB'=20)
('KASTEEL'=20)
('MONUMENT'=20)
('WATERMOLEN'=20)
('WINDMOLEN'=20)
('KAAI'=21)
('NIJV/GROND'=21)
('SPOORWEG'=21)
('WERF'=21)
('AFVALVERW.'=22)
('CABINE'=22)
('ELEK.CABIN'=22)
('GASCABINE'=22)
('LUCHTHAVEN'=22)
('PYLOON'=22)
('STATION'=22)
('TEL/CEL'=22)
('TELECOM/G.'=22)
('WACHTHUIS'=22)
('WATERTOREN'=22)
('WATERWINN.'=22)
('ZUIVER/INS'=22)
('BIBLIOTH.'=23)
('MUSEUM'=23)
('ONDERZOEKC'=23)
('SCHOOLGEB.'=23)
('UNIVERSIT.'=23)
('ADMIN.GEB.'=24)
('GEM/HUIS'=24)
('GENDARMER.'=24)
('GERECHTSH.'=24)
('GEZANTSCH.'=24)
('GOUVER/GEB'=24)
('K.PALEIS'=24)
('MILIT.GEB.'=24)
('STRAFINR.'=24)
('HANGAR'=25)
('MAGAZIJN'=25)
('PARK'=26)
('PUIN'=27)
('BADINRICHT'=28)
('BIOSCOOP'=28)
('CASINO'=28)
('FEESTZAAL'=28)
('JEUGDHEEM'=28)
('KAMPEERT.'=28)
('KULT.CENTR'=28)
('PAVILJOEN'=28)
('SPEELTERR.'=28)
('SPEKT/ZAAL'=28)
('SPORTGEB.'=28)
('SPORTTERR.'=28)
('THEATER'=28)
('VAKAN/TEH.'=28)
('VAKAN/VERB'=28)
('SERRE'=29)
('BESCHER/W.'=30)
('KINDERBEW.'=30)
('KUURINR.'=30)
('LIJKENHUIS'=30)
('RUSTHUIS'=30)
('VERPL/INR.'=30)
('WEESHUIS'=30)
('WELZIJNSG.'=30)
('BEB.OPP.G'=31)
('BEB.OPP.N'=31)
('BEB.OPP.U'=31)
('TUIN'=32)
('BOOMKWEK.'=33)
('WARMOESGR.'=33)
('WEILAND'=34)
('AANSPOEL.'=35)
('DIJK'=35)
('HEIDE'=35)
('MOERAS'=35)
('STORT.WGR.'=35)
('WAL'=35)
('WOESTE GR.'=35)
('BEDRIJFSC#'=36)
('GROND'=36)
('MAT.& OUT.'=36)
('UITKIJK'=36) into NIS_rubriek.

value labels nis_rubriek
1 'Afzonderlijke appartementen (met KI, zonder oppervlakte)'
2 'Allerlei handelsinrichtingen'
3 'Ambachts- en industriegebouwen'
4 'Andere'
5 'Banken, kantoren'
6 'Bijgebouwen'
7 'Boomgaard'
8 'Bos'
9 'Bouwland'
10 'Bouwpercelen'
11 'Building'
12 'Eredienst'
13 'Fictieve percelen appartementsgebouw (zonder KI, met oppervlakte)'
14 'Gekadastreerde wateren'
15 'Gekadastreerde wegen'
16 'Hooiland'
17 'Horeca'
18 'Huis, hoeve'
19 'Landelijke bijgebouwen'
20 'Monumenten'
21 'Nijverheidsgronden'
22 'Nutsvoorzieningen'
23 'Onderwijs, onderzoek en cultuur'
24 'Openbare gebouwen'
25 'Opslagruimte'
26 'Park'
27 'Puin'
28 'Recreatie, sport'
29 'Serre'
30 'Sociale Zorg en ziekenzorg'
31 'Splitsing voor grond en gebouw'
32 'Tuin'
33 'Tuinbouwgronden'
34 'Weiland'
35 'Woeste gronden'
36 'niet toegewezen'.

if art_aard='BEB.OPP.A' nis_app_building=1.
if art_aard='BUILDING' nis_app_building=1.
if art_aard='D.AP.GEB.#' nis_app_building=1.
if art_aard='G.D.AP.GEB' nis_app_building=1.
if art_aard='M.D.AP.GEB' nis_app_building=1.
if art_aard='OPP.& G.D.' nis_app_building=1.
if ltrim(rtrim(art_aard))='AFDAK' nis_huis_hoeve=1.
if art_aard='BERGPLAATS' nis_huis_hoeve=1.
if art_aard='DUIVENTIL' nis_huis_hoeve=1.
if art_aard='G.VEETEELT' nis_huis_hoeve=1.
if art_aard='GARAGE' nis_huis_hoeve=1.
if art_aard='HOEVE' nis_huis_hoeve=1.
if art_aard='HUIS' nis_huis_hoeve=1.
if art_aard='HUIS#' nis_huis_hoeve=1.
if art_aard='K.VEETEELT' nis_huis_hoeve=1.
if art_aard='KROTWONING' nis_huis_hoeve=1.
if art_aard='LANDGEBOUW' nis_huis_hoeve=1.
if art_aard='LAVATORY' nis_huis_hoeve=1.
if art_aard='NOODWONING' nis_huis_hoeve=1.
if art_aard='PAARDESTAL' nis_huis_hoeve=1.
if art_aard='PADDEST/KW' nis_huis_hoeve=1.
if art_aard='SERRE' nis_huis_hoeve=1.
if art_aard='AARDEW/FAB' nis_industrie=1.
if art_aard='BAKKERIJ' nis_industrie=1.
if art_aard='BOUWMAT/F.' nis_industrie=1.
if art_aard='BROUWERIJ' nis_industrie=1.
if art_aard='CEMENTFAB.' nis_industrie=1.
if art_aard='CHEMIC/FAB' nis_industrie=1.
if art_aard='COKESFABR.' nis_industrie=1.
if art_aard='CONSTR/WPL' nis_industrie=1.
if art_aard='DRANKFABR.' nis_industrie=1.
if art_aard='DROOGINST.' nis_industrie=1.
if art_aard='DRUKKERIJ' nis_industrie=1.
if art_aard='ELEK.CENTR' nis_industrie=1.
if art_aard='ELEK.MAT.F.' nis_industrie=1.
if art_aard='GAR.WERKPL' nis_industrie=1.
if art_aard='GASFABRIEK' nis_industrie=1.
if art_aard='GAZOMETER' nis_industrie=1.
if art_aard='GEBRUIKS/F' nis_industrie=1.
if art_aard='GLASFABR.' nis_industrie=1.
if art_aard='HOOGOVEN' nis_industrie=1.
if art_aard='IJSFABRIEK' nis_industrie=1.
if art_aard='KALKHOVEN' nis_industrie=1.
if art_aard='KLEDINGFAB' nis_industrie=1.
if art_aard='KOELINR.' nis_industrie=1.
if art_aard='KOFFIEFAB.' nis_industrie=1.
if art_aard='KOLENMIJN' nis_industrie=1.
if art_aard='LEDERWAR/F' nis_industrie=1.
if art_aard='MAALDERIJ' nis_industrie=1.
if art_aard='MAT. & OUT.' nis_industrie=1.
if art_aard='METAALNIJV' nis_industrie=1.
if art_aard='MEUBELFAB.' nis_industrie=1.
if art_aard='NIJV/GEB.' nis_industrie=1.
if art_aard='PAPIERFAB.' nis_industrie=1.
if art_aard='PETROL/RAF' nis_industrie=1.
if art_aard='PLAST/FAB.' nis_industrie=1.
if art_aard='RESERVOIR' nis_industrie=1.
if art_aard='RUBBERFAB.' nis_industrie=1.
if art_aard='SCHRIJNW.' nis_industrie=1.
if art_aard='SILO' nis_industrie=1.
if art_aard='SLACHTERIJ' nis_industrie=1.
if art_aard='SMIDSE' nis_industrie=1.
if art_aard='SPEELG/FAB' nis_industrie=1.
if art_aard='STEENBAKK.' nis_industrie=1.
if art_aard='TABAKFABR.' nis_industrie=1.
if art_aard='TEXTIELFAB' nis_industrie=1.
if art_aard='VEEVOE/FAB' nis_industrie=1.
if art_aard='VERFFABR.' nis_industrie=1.
if art_aard='VLEESW/FAB' nis_industrie=1.
if art_aard='VOEDINGS/F' nis_industrie=1.
if art_aard='WASSERIJ' nis_industrie=1.
if art_aard='WERKPLAATS' nis_industrie=1.
if art_aard='ZAGERIJ' nis_industrie=1.
if art_aard='ZUIVELFAB.' nis_industrie=1.
if art_aard='HANGAR' nis_opslag=1.
if art_aard='MAGAZIJN' nis_opslag=1.
if art_aard='BANK' nis_kantoor=1.
if art_aard='BEURS' nis_kantoor=1.
if art_aard='KANTOORGEB' nis_kantoor=1.
if art_aard='DIERENGEB.' nis_commercieel=1.
if art_aard='DRANKHUIS' nis_commercieel=1.
if art_aard='GAR.STELPL' nis_commercieel=1.
if art_aard='GR.WARENH.' nis_commercieel=1.
if art_aard='HAND/HUIS' nis_commercieel=1.
if art_aard='HOTEL' nis_commercieel=1.
if art_aard='KIOSK' nis_commercieel=1.
if art_aard='OVER.MARKT' nis_commercieel=1.
if art_aard='PARKEERGEB' nis_commercieel=1.
if art_aard='RESTAURANT' nis_commercieel=1.
if art_aard='SERV.STAT.' nis_commercieel=1.
if art_aard='TOONZAAL' nis_commercieel=1.
if art_aard='ADMIN.GEB.' nis_ander=1.
if art_aard='AFVALVERW.' nis_ander=1.
if art_aard='BADINRICHT' nis_ander=1.
if art_aard='BESCHER/W.' nis_ander=1.
if art_aard='BIBLIOTH.' nis_ander=1.
if art_aard='BIOSCOOP' nis_ander=1.
if art_aard='BISDOM' nis_ander=1.
if art_aard='CABINE' nis_ander=1.
if art_aard='CASINO' nis_ander=1.
if art_aard='ELEK.CABIN' nis_ander=1.
if art_aard='FEESTZAAL' nis_ander=1.
if art_aard='GASCABINE' nis_ander=1.
if art_aard='GEB.ERED.' nis_ander=1.
if art_aard='GEM/HUIS' nis_ander=1.
if art_aard='GENDARMER.' nis_ander=1.
if art_aard='GERECHTSH.' nis_ander=1.
if art_aard='GEZANTSCH.' nis_ander=1.
if art_aard='GOUVER/GEB' nis_ander=1.
if art_aard='HISTOR.GEB' nis_ander=1.
if art_aard='JEUGDHEEM' nis_ander=1.
if art_aard='K.PALEIS' nis_ander=1.
if art_aard='KAPEL' nis_ander=1.
if art_aard='KASTEEL' nis_ander=1.
if art_aard='KERK' nis_ander=1.
if art_aard='KINDERBEW.' nis_ander=1.
if art_aard='KLOOSTER' nis_ander=1.
if art_aard='KULT.CENTR' nis_ander=1.
if art_aard='KUURINR.' nis_ander=1.
if art_aard='LIJKENHUIS' nis_ander=1.
if art_aard='LUCHTHAVEN' nis_ander=1.
if art_aard='MILIT.GEB.' nis_ander=1.
if art_aard='MONUMENT' nis_ander=1.
if art_aard='MOSKEE' nis_ander=1.
if art_aard='MUSEUM' nis_ander=1.
if art_aard='ONDERGR. R.' nis_ander=1.
if art_aard='ONDERZOEKC' nis_ander=1.
if art_aard='PASTORIE' nis_ander=1.
if art_aard='PAVILJOEN' nis_ander=1.
if art_aard='PUIN' nis_ander=1.
if art_aard='PYLOON' nis_ander=1.
if art_aard='RUSTHUIS' nis_ander=1.
if art_aard='SCHOOLGEB.' nis_ander=1.
if art_aard='SEMINARIE' nis_ander=1.
if art_aard='SPEKT/ZAAL' nis_ander=1.
if art_aard='SPORTGEB.' nis_ander=1.
if art_aard='STATION' nis_ander=1.
if art_aard='STRAFINR.' nis_ander=1.
if art_aard='SYNAGOGE' nis_ander=1.
if art_aard='TEL/CEL' nis_ander=1.
if art_aard='TELECOM/G.' nis_ander=1.
if art_aard='TEMPEL' nis_ander=1.
if art_aard='THEATER' nis_ander=1.
if art_aard='UNIVERSIT.' nis_ander=1.
if art_aard='VAKAN/TEH.' nis_ander=1.
if art_aard='VAKAN/VERB' nis_ander=1.
if art_aard='VERPL/INR.' nis_ander=1.
if art_aard='WACHTHUIS' nis_ander=1.
if art_aard='WATERMOLEN' nis_ander=1.
if art_aard='WATERTOREN' nis_ander=1.
if art_aard='WATERWINN.' nis_ander=1.
if art_aard='WEESHUIS' nis_ander=1.
if art_aard='WELZIJNSG.' nis_ander=1.
if art_aard='WINDMOLEN' nis_ander=1.
if art_aard='ZUIVER/INS' nis_ander=1.
if art_aard='AANSPOEL.' nis_onbebouwd=1.
if art_aard='BASSIN GEW' nis_onbebouwd=1.
if art_aard='BEB.OPP.G' nis_onbebouwd=1.
if art_aard='BEB.OPP.N' nis_onbebouwd=1.
if art_aard='BEB.OPP.U' nis_onbebouwd=1.
if art_aard='BOOMG.HOOG' nis_onbebouwd=1.
if art_aard='BOOMG.LAAG' nis_onbebouwd=1.
if art_aard='BOOMKWEK.' nis_onbebouwd=1.
if art_aard='BOS' nis_onbebouwd=1.
if art_aard='BOUWGROND' nis_onbebouwd=1.
if art_aard='BOUWLAND' nis_onbebouwd=1.
if art_aard='D.PARKING#' nis_onbebouwd=1.
if art_aard='DIJK' nis_onbebouwd=1.
if art_aard='GRACHT' nis_onbebouwd=1.
if art_aard='HEIDE' nis_onbebouwd=1.
if art_aard='HOOILAND' nis_onbebouwd=1.
if art_aard='KAAI' nis_onbebouwd=1.
if art_aard='KAMPEERT.' nis_onbebouwd=1.
if art_aard='KANAAL' nis_onbebouwd=1.
if art_aard='KERKHOF' nis_onbebouwd=1.
if art_aard='KOER' nis_onbebouwd=1.
if art_aard='MEER' nis_onbebouwd=1.
if art_aard='MILIT.TERR' nis_onbebouwd=1.
if art_aard='MOERAS' nis_onbebouwd=1.
if art_aard='NIJV/GROND' nis_onbebouwd=1.
if art_aard='PARK' nis_onbebouwd=1.
if art_aard='PARKING' nis_onbebouwd=1.
if art_aard='PLEIN' nis_onbebouwd=1.
if art_aard='POEL' nis_onbebouwd=1.
if art_aard='SLOOT' nis_onbebouwd=1.
if art_aard='SPEELTERR.' nis_onbebouwd=1.
if art_aard='SPOORWEG' nis_onbebouwd=1.
if art_aard='SPORTTERR.' nis_onbebouwd=1.
if art_aard='STORT.WGR.' nis_onbebouwd=1.
if art_aard='TUIN' nis_onbebouwd=1.
if art_aard='VIJVER' nis_onbebouwd=1.
if art_aard='VLIEGVELD' nis_onbebouwd=1.
if art_aard='WAL' nis_onbebouwd=1.
if art_aard='WARMOESGR.' nis_onbebouwd=1.
if art_aard='WEG' nis_onbebouwd=1.
if art_aard='WEILAND' nis_onbebouwd=1.
if art_aard='WERF' nis_onbebouwd=1.
if art_aard='WOESTE GR.' nis_onbebouwd=1.
if art_aard='BEDRIJFSC#' nis_niettoegekend=1.
if art_aard='GROND' nis_niettoegekend=1.
if art_aard='MAT.& OUT.' nis_niettoegekend=1.
if art_aard='UITKIJK' nis_niettoegekend=1.







* kadastraal inkomen.
* dit bestaat uit onbelastbaar en belastbaar kadastraal inkomen.
* deze informatie zit verspreid over vier velden: ri1, ri2 en cod1, cod2.

* zorg dat de ri variabelen numeriek zijn, ze bevatten de waarden.
alter type ri1 (f8.0).

* de cod variabele omvatten info over belastbaar/onbelastbaar.
string  cod1_positie2 (a1).
compute cod1_positie2=char.substr(cod1,2,1).
string  cod2_positie2 (a1).
compute cod2_positie2=char.substr(cod2,2,1).

* cod = F, K, P of L betekent belastbaar kadastraal inkomen.
if cod1_positie2="F" | cod1_positie2="P" | cod1_positie2="K" | cod1_positie2="L" ki_deel1=ri1.
if cod2_positie2="F" | cod2_positie2="P" | cod2_positie2="K" | cod2_positie2="L" ki_deel2=ri2.
recode ki_deel1 ki_deel2 (missing=0).
compute KI_belastbaar=ki_deel1+ki_deel2.

* bij andere letters betreffen de variabelen onbelastbaar inkomen.
if ~(cod1_positie2="F" | cod1_positie2="P" | cod1_positie2="K" | cod1_positie2="L") ki_onbelast_deel1=ri1.
if ~(cod2_positie2="F" | cod2_positie2="P" | cod2_positie2="K" | cod2_positie2="L") ki_onbelast_deel2=ri2.
recode ki_onbelast_deel1 ki_onbelast_deel2 (missing=0).
compute KI_onbelastbaar=ki_onbelast_deel1+ki_onbelast_deel2.

execute.
delete variables cod1_positie2	
cod2_positie2			
ki_deel1			
ki_deel2 ki_onbelast_deel1			
ki_onbelast_deel2.

SAVE OUTFILE='' + basismap + 'werkbestanden\werkbestand_gebouwdelen.sav'
  /COMPRESSED.
