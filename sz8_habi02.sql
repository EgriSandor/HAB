Keressük meg, hogy az egyes autókat mikor értékelték fel utoljára? ;
select au.azon, au.rendszam, to_char(max(af.datum),'yyyy.mm.dd')
from szerelo.sz_auto au left outer join szerelo.sz_autofelertekeles af
on au.azon=af.auto_azon
group by au.azon, au.rendszam;

Keressük meg, hogy az egyes autókat mikor adták el utoljára;
select au.rendszam, au.azon, max(atu.vasarlas_ideje)
from szerelo.sz_auto au left outer join SZERELO.sz_auto_tulajdonosa atu
on au.azon=atu.auto_azon
group by au.rendszam, au.azon;


Keressük meg, hogy az egyes autóknak ki az utolsó tulajdonosa;
select *
from szerelo.sz_auto_tulajdonosa atu2 inner join 
     (select atu.auto_azon, max(atu.vasarlas_ideje) vasarlas_ideje
      from szerelo.sz_auto_tulajdonosa atu
      group by atu.auto_azon) maxt
on atu2.auto_azon=maxt.auto_azon and atu2.vasarlas_ideje=maxt.vasarlas_ideje;

select *
from szerelo.sz_auto_tulajdonosa atu2 
where (auto_azon, vasarlas_ideje) in (select atu.auto_azon, max(atu.vasarlas_ideje) 
                                      from szerelo.sz_auto_tulajdonosa atu
                                      group by atu.auto_azon) ;
                                      
                                      
select au.rendszam, tu.nev
from szerelo.sz_auto au left outer join szerelo.sz_auto_tulajdonosa atu2 
on au.azon=atu2.auto_azon
left outer join SZERELO.sz_tulajdonos tu
on atu2.tulaj_azon=tu.azon
where (auto_azon, vasarlas_ideje) in (select atu.auto_azon, max(atu.vasarlas_ideje) 
                                      from szerelo.sz_auto_tulajdonosa atu
                                      group by atu.auto_azon);
                                      
with 
seged as (select atu2.auto_azon, atu2.vasarlas_ideje, atu2.tulaj_azon
          from szerelo.sz_auto_tulajdonosa atu2 inner join 
               (select atu.auto_azon, max(atu.vasarlas_ideje) vasarlas_ideje
                from szerelo.sz_auto_tulajdonosa atu
                group by atu.auto_azon) maxt
          on atu2.auto_azon=maxt.auto_azon 
          and atu2.vasarlas_ideje=maxt.vasarlas_ideje)
          
select au.rendszam, tu.nev 
from szerelo.sz_auto au left outer join seged 
on au.azon=seged.auto_azon
left outer join SZERELO.sz_tulajdonos tu
on seged.tulaj_azon=tu.azon;     

Hozzunk létre nézetet, amely az autó tulajdonosa táblát kiegészíti egy eladás ideje oszloppal, 
amiben ugyannak az autónak a következõ eladásának a vásárlási ideje van.

select atu.auto_azon, atu.tulaj_azon, 
atu.vasarlas_ideje, kovetkezo.vasarlas_ideje kov_vi
from SZERELO.sz_auto_tulajdonosa atu inner join
szerelo.sz_auto_tulajdonosa kovetkezo
on atu.auto_azon=kovetkezo.auto_azon
where kovetkezo.vasarlas_ideje =(select min(vasarlas_ideje) 
                                from SZERELO.sz_auto_tulajdonosa atu3
                                where atu3.vasarlas_ideje>atu.vasarlas_ideje
                                and atu3.auto_azon=atu.auto_azon)
union all 
select atu4.auto_azon, atu4.tulaj_azon, 
atu4.vasarlas_ideje, null
from SZERELO.sz_auto_tulajdonosa atu4
where atu4.auto_azon not in 
  (select auto_azon
     from SZERELO.sz_auto_tulajdonosa atu5
    where atu5.vasarlas_ideje>atu4.vasarlas_ideje)
order by auto_azon, vasarlas_ideje;

Melyik típushoz tartozik a legtöbb autó?;
select ati.megnevezes, ati.marka, count(au.azon)
from SZERELO.sz_autotipus ati left outer join
SZERELO.sz_auto au
on ati.azon=au.tipus_azon
group by ati.megnevezes, ati.marka
having count(au.azon)= (select max(count(au.azon))
                        from SZERELO.sz_autotipus ati left outer join
                        SZERELO.sz_auto au
                         on ati.azon=au.tipus_azon
                         group by ati.megnevezes, ati.marka);

Melyik típushoz tartozik a legkevesebb autó?

select ati.megnevezes, ati.marka, count(au.azon)
from SZERELO.sz_autotipus ati left outer join
SZERELO.sz_auto au
on ati.azon=au.tipus_azon
group by ati.megnevezes, ati.marka
having count(au.azon)= (select min(count(au.azon))
                        from SZERELO.sz_autotipus ati left outer join
                        SZERELO.sz_auto au
                         on ati.azon=au.tipus_azon
                         group by ati.megnevezes, ati.marka);

Melyik autóhoz tartozik a legkevesebb szerelési összeg?;
select au.azon, au.rendszam, sum(nvl(munkavegzes_ara,0))
from szerelo.sz_auto au left outer join 
szerelo.sz_szereles sz
on au.azon=sz.auto_azon
group by au.azon, au.rendszam
having sum(nvl(munkavegzes_ara,0))= (select min(sum(nvl(munkavegzes_ara,0)))
                                     from szerelo.sz_auto au left outer join 
                                          szerelo.sz_szereles sz
                                       on au.azon=sz.auto_azon
                                     group by au.azon, au.rendszam);

Hol dolgozik a legidõsebb szerelõ?;
select muhely_azon, mu.nev
from szerelo.sz_szerelo sz left outer join 
SZERELO.sz_dolgozik d
on sz.azon=d.szerelo_azon
left outer join SZERELO.sz_szerelomuhely mu
on d.muhely_azon=mu.azon
where szul_dat=(select min(szul_dat) from szerelo.sz_szerelo);

Töröljük azokat a szereléseket, amelyekhez tartozó 
autót utoljára xy vásárolta meg;
select * from szerelo.sz_szereles
where auto_azon in (select auto_azon from szerelo.sz_auto_tulajdonosa atu
                    where atu.tulaj_azon=(select azon from SZERELO.sz_tulajdonos t
                                          where t.nev='Kiss Zoltán')
                        and (atu.vasarlas_ideje, auto_azon) in (select max(vasarlas_ideje), auto_azon
                                                from szerelo.sz_auto_tulajdonosa
                                                where tulaj_azon=
                                                    (select azon from SZERELO.sz_tulajdonos t
                                                                 where t.nev='Kiss Zoltán')
                                                group by auto_azon));
                                          
select *
from szerelo.sz_auto_tulajdonosa
order by auto_azon;


Töröljük azokat a szereléseket, amelyekhez tartozó autó elsõ vásárlási ára kevesebb, 
mint az adott szerelése 100-szorosa.

Módosítsuk azon szereléseket, amelyek olyan autókhoz tartoznak, amelyeknek esetén a szerelés kezdete 
5 évvel késõbb kezdõdött, mint az elsõ vásárlási ár. 
A szerelés munkavégzésének az ára legyen a az eredeti munkavégzés ára minusz 
az autó elsõ vásárlási árának az 1 százaléka
