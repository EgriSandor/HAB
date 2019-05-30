Keress�k meg, hogy az egyes aut�kat mikor �rt�kelt�k fel utolj�ra? ;
select au.azon, au.rendszam, to_char(max(af.datum),'yyyy.mm.dd')
from szerelo.sz_auto au left outer join szerelo.sz_autofelertekeles af
on au.azon=af.auto_azon
group by au.azon, au.rendszam;

Keress�k meg, hogy az egyes aut�kat mikor adt�k el utolj�ra;
select au.rendszam, au.azon, max(atu.vasarlas_ideje)
from szerelo.sz_auto au left outer join SZERELO.sz_auto_tulajdonosa atu
on au.azon=atu.auto_azon
group by au.rendszam, au.azon;


Keress�k meg, hogy az egyes aut�knak ki az utols� tulajdonosa;
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

Hozzunk l�tre n�zetet, amely az aut� tulajdonosa t�bl�t kieg�sz�ti egy elad�s ideje oszloppal, 
amiben ugyannak az aut�nak a k�vetkez� elad�s�nak a v�s�rl�si ideje van.

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

Melyik t�pushoz tartozik a legt�bb aut�?;
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

Melyik t�pushoz tartozik a legkevesebb aut�?

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

Melyik aut�hoz tartozik a legkevesebb szerel�si �sszeg?;
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

Hol dolgozik a legid�sebb szerel�?;
select muhely_azon, mu.nev
from szerelo.sz_szerelo sz left outer join 
SZERELO.sz_dolgozik d
on sz.azon=d.szerelo_azon
left outer join SZERELO.sz_szerelomuhely mu
on d.muhely_azon=mu.azon
where szul_dat=(select min(szul_dat) from szerelo.sz_szerelo);

T�r�lj�k azokat a szerel�seket, amelyekhez tartoz� 
aut�t utolj�ra xy v�s�rolta meg;
select * from szerelo.sz_szereles
where auto_azon in (select auto_azon from szerelo.sz_auto_tulajdonosa atu
                    where atu.tulaj_azon=(select azon from SZERELO.sz_tulajdonos t
                                          where t.nev='Kiss Zolt�n')
                        and (atu.vasarlas_ideje, auto_azon) in (select max(vasarlas_ideje), auto_azon
                                                from szerelo.sz_auto_tulajdonosa
                                                where tulaj_azon=
                                                    (select azon from SZERELO.sz_tulajdonos t
                                                                 where t.nev='Kiss Zolt�n')
                                                group by auto_azon));
                                          
select *
from szerelo.sz_auto_tulajdonosa
order by auto_azon;


T�r�lj�k azokat a szerel�seket, amelyekhez tartoz� aut� els� v�s�rl�si �ra kevesebb, 
mint az adott szerel�se 100-szorosa.

M�dos�tsuk azon szerel�seket, amelyek olyan aut�khoz tartoznak, amelyeknek eset�n a szerel�s kezdete 
5 �vvel k�s�bb kezd�d�tt, mint az els� v�s�rl�si �r. 
A szerel�s munkav�gz�s�nek az �ra legyen a az eredeti munkav�gz�s �ra minusz 
az aut� els� v�s�rl�si �r�nak az 1 sz�zal�ka
