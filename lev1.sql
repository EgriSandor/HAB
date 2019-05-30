List�zzuk a piros, k�k �s fekete aut�k azonos�t�j�t, rendsz�m�t �s sz�n�t.
A lista legyen rendsz�m szerint rendezett

SELECT AZON, RENDSZAM, SZIN
FROM SZERELO.sz_auto
WHERE SZIN IN ('piros', 'k�k', 'fekete')
ORDER BY RENDSZAM;

Az Opel m�rk�j� aut�k rendsz�ma. A lista legyen cs�kken�en rendezett.

SELECT a.RENDSZAM
FROM SZERELO.sz_auto a
JOIN SZERELO.sz_autotipus t on t.AZON = a.TIPUS_AZON
WHERE t.MARKA = 'Opel'
ORDER BY a.RENDSZAM DESC

Sz�nenk�nt h�ny aut� van?
Rendezz�k a list�t darabsz�m szerint cs�kken�en.;
select szin, count(*) db
from szerelo.sz_auto
group by szin 
order by db desc;


Az egyes szerel�m�helyekben h�ny lez�ratlan szerel�s van?
A list�t rendezz�k a lez�ratlan szerel�sek sz�ma szerint cs�kken�en, 
azon bel�l a szerel�m�hely neve szerint.;
select m.nev, count(szereles_kezdete) db
from szerelo.sz_szerelomuhely m inner join
szerelo.sz_szereles sz
on m.azon=sz.muhely_azon
where szereles_vege is null
group by m.nev, m.azon
order by db desc, nev;

List�zzuk az �sszes debreceni tulajdonost, �s ha van aut�juk akkor annak az azonos�t�j�t.
A lista legyen a tulaj neve szerint rendezett.
select nev, auto_azon
from szerelo.sz_tulajdonos tu left outer join szerelo.sz_auto_tulajdonosa atu
on tu.azon=atu.tulaj_azon
where cim like 'Debrecen,%'
order by nev;

List�zzuk ki, hogy a piros aut�kat h�nyszor szerelt�k?;
select rendszam, count(szereles_kezdete), szin
from szerelo.sz_auto au left outer join
szerelo.sz_szereles sz
on sz.auto_azon=au.azon
where szin='piros'
group by rendszam, szin;

Kik azok a szerel�k, akik 2-n�l t�bb helyen dolgoztak?
select nev, sz.azon, count(d.muhely_azon)
from szerelo.sz_szerelo sz inner join szerelo.sz_dolgozik d
on sz.azon=d.szerelo_azon
group by nev, sz.azon
having count(d.muhely_azon)>2;

Melyik az a tulajdonos, aki 3-n�l kevesebb aut�t birtokolt valamikor?
select azon, nev, count(auto_azon)
from szerelo.sz_tulajdonos tu left outer join
SZERELO.sz_auto_tulajdonosa atu
on tu.azon=atu.tulaj_azon
group by azon, nev
having count(auto_azon)<3;

Melyik aut�t adj�k el utolj�ra az els� v�s�rl�si d�tum alapj�n?;
select *
from szerelo.sz_auto ak
where ak.elso_vasarlas_idopontja=(select max(au.elso_vasarlas_idopontja) from szerelo.sz_auto au);

Melyik piros aut�t adj�k el utolj�ra az els� v�s�rl�si d�tum alapj�n?;
select *
from szerelo.sz_auto ak
where szin='piros'
and ak.elso_vasarlas_idopontja=(select max(au.elso_vasarlas_idopontja) from szerelo.sz_auto au
                            where szin='piros');

Mely aut�kat nem szerelt�k?
select *
from szerelo.sz_auto
where azon not in (select auto_azon from szerelo.sz_szereles);

select azon, rendszam
from szerelo.sz_auto left outer join szerelo.sz_szereles
on azon=auto_azon
where auto_azon is null;

Melyik aut�t �rt�kelt�k fel a legt�bbsz�r/legkevesebb?
select rendszam, au.azon, count(datum)
from szerelo.sz_auto au left outer join 
szerelo.sz_autofelertekeles af
on af.auto_azon=au.azon
group by rendszam, au.azon
having count(datum)=(select min(count(datum))
                     from szerelo.sz_auto au left outer join 
                     szerelo.sz_autofelertekeles af
                      on af.auto_azon=au.azon
                      group by rendszam, au.azon);
                      
A legdr�g�bb piros aut� �sszes szerel�s�hez a munkav�gz�s �r�t emelj�k meg annyival, 
ah�ny napot az aut� a szerel�m�helyben t�lt�tt.
Csak ott ott m�dos�tsunk,ahol a szerel�st m�r befejezt�k.
create table szereles as
select *
from szerelo.sz_szereles;

update szereles
set munkavegzes_ara=munkavegzes_ara+(szereles_vege-szereles_kezdete)
where auto_azon=(select azon
                 from szerelo.sz_auto
                 where szin='piros'
                 and elso_vasarlasi_ar=(select max(elso_vasarlasi_ar) from szerelo.sz_auto
                                        where szin='piros'))
and szereles_vege is not null;  

T�r�lj�k azokat az aut�kat, amelyekhez nem tartozik aut�fel�rt�kel�s
create table auto as select * from szerelo.sz_auto;
delete 
from auto
where azon not in (select auto_azon from SZERELO.sz_autofelertekeles);

T�r�lj�k azokat az aut�fel�rt�kel�seket, amelyekben szerepl� �rt�k t�bb, 
mint az aut� els� v�r�sl�si �r�nak a70%-a.

delete
from autofelertekeles af
where auto_azon in (select azon from auto a where af.ertek>a.elso_vasarlasi_ara*0.7);

alter table auto add constraint au_pk primary key (azon);
create table szerelo as select * from szerelo.sz_szerelo;
alter table szerelo add constraint sz2_pk primary key (azon);

create table forg_kivon
(auto_azon number(5),
datum date,
szerelo number(5),
constraint fg_pk primary key (auto_azon),
constraint fg_fk_au foreign key (auto_azon) references auto(azon),
constraint fg_fk_sz foreign key (szerelo) references szerelo,
constraint fg_uq unique (szerelo,datum));

insert into forg_kivon(auto_azon, datum, szerelo)
values (158, to_date('2019.03.01','yyyy.mm.dd'),305 );

insert into forg_kivon(auto_azon, datum, szerelo)
values (159, to_date('2019.03.02','yyyy.mm.dd'),305)

insert into forg_kivon(auto_azon, datum, szerelo)
values (160, to_date('2019.03.02','yyyy.mm.dd'),100);

commit;

Koz�k Danuta csapat�nak a neve
select csn.nev
from olimpia.o_versenyzok v inner join
olimpia.o_csapattagok cs
on v.azon=cs.versenyzo_azon
inner join olimpia.o_versenyzok csn
on cs.csapat_azon=csn.azon
where v.nev='Koz�k Danuta';

Kik Koz�k Danuta csapatt�rsai?
select tarsak.nev
from olimpia.o_versenyzok dk
inner join OLIMPIA.o_csapattagok dkcs
on dk.azon=dkcs.versenyzo_azon
inner join OLIMPIA.o_csapattagok cst
on cst.csapat_azon=dkcs.csapat_azon
inner join olimpia.o_versenyzok tarsak
on cst.versenyzo_azon=tarsak.azon
where dk.nev='Koz�k Danuta';

Neena Kochaar-nak ki a f�n�ke?
hr s�ma: hr.employees t�bla








                      

                      





