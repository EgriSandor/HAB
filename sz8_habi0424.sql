create table auto as select * from szerelo.sz_auto;
alter table auto 
add constraint a_pk primary key (azon);

alter table auto 
add constraint a_uq unique (rendszam);

create or replace procedure proc_auto_insert(
    p_azon auto.azon%type,
    p_szin auto.szin%type,
    p_elso_vasarlas_idopontja auto.elso_vasarlas_idopontja%type,
    p_elso_vasarlasi_ar auto.elso_vasarlasi_ar%type,
    p_tipus_azon auto.tipus_azon%type,
    p_rendszam auto.rendszam%type) is
    kiv exception;
    pragma exception_init(kiv,-1400);
begin
INSERT INTO auto (    azon,    szin,    elso_vasarlas_idopontja,    elso_vasarlasi_ar,
    tipus_azon,    rendszam) 
VALUES (p_azon,p_szin,p_elso_vasarlas_idopontja,p_elso_vasarlasi_ar,
    p_tipus_azon,p_rendszam
);
exception 
 when dup_val_on_index
 then dopl('Már van ilyen autó'||p_azon||' '||p_rendszam);
 when kiv then dopl('A rendszámot ki kell tölteni');
end;

alter table auto 
modify rendszam varchar2(10) not null;


DECLARE
    p_azon                      NUMBER;
    p_szin                      VARCHAR2(20);
    p_elso_vasarlas_idopontja   DATE;
    p_elso_vasarlasi_ar         NUMBER;
    p_tipus_azon                NUMBER;
    p_rendszam                  VARCHAR2(10);
BEGIN
    p_azon := 10;
    p_szin := 'piros';
    p_elso_vasarlas_idopontja := NULL;
    p_elso_vasarlasi_ar := NULL;
    p_tipus_azon := NULL;
    p_rendszam := NULL;
    proc_auto_insert(p_azon => p_azon, p_szin => p_szin, 
    p_elso_vasarlas_idopontja => p_elso_vasarlas_idopontja, p_elso_vasarlasi_ar
    => p_elso_vasarlasi_ar, p_tipus_azon => p_tipus_azon, p_rendszam => p_rendszam);
--rollback; 

END;


create or replace procedure proc_auto_insert(
    p_azon auto.azon%type,
    p_szin auto.szin%type:='piros',
    p_elso_vasarlas_idopontja auto.elso_vasarlas_idopontja%type:=sysdate,
    p_elso_vasarlasi_ar auto.elso_vasarlasi_ar%type,
    p_tipus SZERELO.sz_autotipus.megnevezes%type:='Octavia',
    p_rendszam auto.rendszam%type,
    
    p_auto out auto%rowtype) is
    v_tipus szerelo.sz_autotipus.azon%type;
    kiv exception;
    pragma exception_init(kiv,-1400);
begin
select azon
into v_tipus
from szerelo.sz_autotipus
where megnevezes=p_tipus;

INSERT INTO auto (    azon,    szin,    elso_vasarlas_idopontja,    elso_vasarlasi_ar,
    tipus_azon,    rendszam) 
VALUES (p_azon,p_szin,p_elso_vasarlas_idopontja,p_elso_vasarlasi_ar,
    v_tipus,p_rendszam)
returning  azon,    szin,    elso_vasarlas_idopontja,    elso_vasarlasi_ar,
    tipus_azon,    rendszam
    into p_auto;
exception 
 when dup_val_on_index
 then dopl('Már van ilyen autó'||p_azon||' '||p_rendszam);
 when kiv then dopl('A rendszámot ki kell tölteni');
end;


create or replace procedure proc_auto_insert(
    p_azon auto.azon%type,
    p_szin auto.szin%type:='piros',
    p_elso_vasarlas_idopontja auto.elso_vasarlas_idopontja%type:=sysdate,
    p_elso_vasarlasi_ar auto.elso_vasarlasi_ar%type,
    p_tipus SZERELO.sz_autotipus.megnevezes%type:='Octavia',
    p_rendszam auto.rendszam%type,
    
    p_auto out auto%rowtype) is
    
    v_tipus szerelo.sz_autotipus.azon%type;
    kiv exception;
    pragma exception_init(kiv,-1400);
    
begin
select azon
into v_tipus
from szerelo.sz_autotipus
where megnevezes=p_tipus;

INSERT INTO auto (    azon,    szin,    elso_vasarlas_idopontja,    elso_vasarlasi_ar,
    tipus_azon,    rendszam) 
VALUES (p_azon,p_szin,p_elso_vasarlas_idopontja,p_elso_vasarlasi_ar,
    v_tipus,p_rendszam)
returning  azon,    szin,    elso_vasarlas_idopontja,    elso_vasarlasi_ar,
    tipus_azon,    rendszam
    into p_auto;
exception 
 when no_data_found then dopl('Nincs ilyen típus:'||p_tipus);
 when dup_val_on_index
 then dopl('Már van ilyen autó'||p_azon||' '||p_rendszam);
 when kiv then dopl('A rendszámot ki kell tölteni');
end;

DECLARE
    p_azon                      NUMBER;
    p_szin                      VARCHAR2(20);
    p_elso_vasarlas_idopontja   DATE;
    p_elso_vasarlasi_ar         NUMBER;
    p_tipus                     VARCHAR2(20);
    p_rendszam                  VARCHAR2(10);
p_auto szerelo.sz_auto%rowtype;
BEGIN
    p_azon := 20;
    p_elso_vasarlasi_ar := 30000;
    p_tipus := 'Cors';
    p_rendszam := 'ASD123';
    
    proc_auto_insert(p_azon => p_azon, 
    
    p_elso_vasarlasi_ar=> p_elso_vasarlasi_ar, 
    p_tipus => p_tipus, 
    p_rendszam => p_rendszam, p_auto => p_auto);
    
    dopl(p_auto.szin||p_auto.tipus_azon);
END;


declare 
v_auto  auto%rowtype;
BEGIN
    proc_auto_insert(30, 'kék', p_auto => v_auto, p_elso_vasarlasi_ar=> '500000', 
    p_rendszam => 'DFG123',    p_tipus => 'Corsa');
    
    dopl(v_auto.szin||v_auto.tipus_azon);
END;

create or replace procedure proba (p_in in varchar2, p_inout in out varchar2, p_out out varchar2) is
begin
dopl('p_in:'||p_in);
dopl('p_inout:'||nvl(p_inout,'null'));
dopl('p_out:'||nvl(p_out,'null'));
--p_in:='almafa';
p_inout:='körtefa';
p_out:='diófa';
--dopl('p_in:'||p_in);
dopl('p_inout:'||p_inout);
dopl('p_out:'||p_out);
end;

declare
  v_inout varchar2(30):='beki';
  v_out varchar2(30):='ki';
begin
proba('be',v_inout,v_out); 
end;

create or replace procedure auto_lista(p_tipus szerelo.sz_autotipus.megnevezes%type) is
begin
for i in (select * 
          from szerelo.sz_auto
          where tipus_azon in (select azon 
                               from szerelo.sz_autotipus
                               where megnevezes=p_tipus))
loop
dopl(i.rendszam||i.szin);
end loop;

end;


begin
auto_lista('Bora');
end;

begin
raise_application_error(-20001,'Hiba');
end;
