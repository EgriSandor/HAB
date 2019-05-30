Listázzuk a piros, kék és fekete autók azonosítóját, rendszámát és színét.
A lista legyen rendszám szerint rendezett

SELECT AZON, RENDSZAM, SZIN
FROM SZERELO.sz_auto
WHERE SZIN IN ('piros', 'kék', 'fekete')
ORDER BY RENDSZAM;

Az Opel márkájú autók rendszáma. A lista legyen csökkenõen rendezett.

SELECT a.RENDSZAM
FROM SZERELO.sz_auto a
JOIN SZERELO.sz_autotipus t on t.AZON = a.TIPUS_AZON
WHERE t.MARKA = 'Opel'
ORDER BY a.RENDSZAM DESC

Színenként hány autó van?
Rendezzük a listát darabszám szerint csökkenõen.;
select szin, count(*) db
from szerelo.sz_auto
group by szin 
order by db desc;


Az egyes szerelõmûhelyekben hány lezáratlan szerelés van?
A listát rendezzük a lezáratlan szerelések száma szerint csökkenõen, 
azon belül a szerelõmûhely neve szerint.;
select m.nev, count(szereles_kezdete) db
from szerelo.sz_szerelomuhely m inner join
szerelo.sz_szereles sz
on m.azon=sz.muhely_azon
where szereles_vege is null
group by m.nev, m.azon
order by db desc, nev;

Listázzuk az összes debreceni tulajdonost, és ha van autójuk akkor annak az azonosítóját.
A lista legyen a tulaj neve szerint rendezett.
select nev, auto_azon
from szerelo.sz_tulajdonos tu left outer join szerelo.sz_auto_tulajdonosa atu
on tu.azon=atu.tulaj_azon
where cim like 'Debrecen,%'
order by nev;

Listázzuk ki, hogy a piros autókat hányszor szerelték?;
select rendszam, count(szereles_kezdete), szin
from szerelo.sz_auto au left outer join
szerelo.sz_szereles sz
on sz.auto_azon=au.azon
where szin='piros'
group by rendszam, szin;

Kik azok a szerelõk, akik 2-nál több helyen dolgoztak?
select nev, sz.azon, count(d.muhely_azon)
from szerelo.sz_szerelo sz inner join szerelo.sz_dolgozik d
on sz.azon=d.szerelo_azon
group by nev, sz.azon
having count(d.muhely_azon)>2;

Melyik az a tulajdonos, aki 3-nál kevesebb autót birtokolt valamikor?
select azon, nev, count(auto_azon)
from szerelo.sz_tulajdonos tu left outer join
SZERELO.sz_auto_tulajdonosa atu
on tu.azon=atu.tulaj_azon
group by azon, nev
having count(auto_azon)<3;

Melyik autót adják el utoljára az elsõ vásárlási dátum alapján?;
select *
from szerelo.sz_auto ak
where ak.elso_vasarlas_idopontja=(select max(au.elso_vasarlas_idopontja) from szerelo.sz_auto au);

Melyik piros autót adják el utoljára az elsõ vásárlási dátum alapján?;
select *
from szerelo.sz_auto ak
where szin='piros'
and ak.elso_vasarlas_idopontja=(select max(au.elso_vasarlas_idopontja) from szerelo.sz_auto au
                            where szin='piros');

Mely autókat nem szerelték?
select *
from szerelo.sz_auto
where azon not in (select auto_azon from szerelo.sz_szereles);

select azon, rendszam
from szerelo.sz_auto left outer join szerelo.sz_szereles
on azon=auto_azon
where auto_azon is null;

Melyik autót értékelték fel a legtöbbször/legkevesebb?
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
                      
A legdrágább piros autó összes szereléséhez a munkavégzés árát emeljük meg annyival, 
ahány napot az autó a szerelõmûhelyben töltött.
Csak ott ott módosítsunk,ahol a szerelést már befejezték.
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

Töröljük azokat az autókat, amelyekhez nem tartozik autófelértékelés
create table auto as select * from szerelo.sz_auto;
delete 
from auto
where azon not in (select auto_azon from SZERELO.sz_autofelertekeles);

Töröljük azokat az autófelértékeléseket, amelyekben szereplõ érték több, 
mint az autó elsõ váráslási árának a70%-a.

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

Kozák Danuta csapatának a neve
select csn.nev
from olimpia.o_versenyzok v inner join
olimpia.o_csapattagok cs
on v.azon=cs.versenyzo_azon
inner join olimpia.o_versenyzok csn
on cs.csapat_azon=csn.azon
where v.nev='Kozák Danuta';

Kik Kozák Danuta csapattársai?
select tarsak.nev
from olimpia.o_versenyzok dk
inner join OLIMPIA.o_csapattagok dkcs
on dk.azon=dkcs.versenyzo_azon
inner join OLIMPIA.o_csapattagok cst
on cst.csapat_azon=dkcs.csapat_azon
inner join olimpia.o_versenyzok tarsak
on cst.versenyzo_azon=tarsak.azon
where dk.nev='Kozák Danuta';

Neena Kochaar-nak ki a fõnöke?
hr séma: hr.employees tábla








                      

                      





