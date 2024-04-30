/*Función Almacenada que permita obtener el nombre completo del administrador del edificio*/
CREATE OR REPLACE PACKAGE PKG_PAGO_DEPTO is
function fn_adm_nombre_completo(edificio in number) RETURN VARCHAR2;
function fn_responsable_nombre(depto in number, fecha_cancelacion in date) return VARCHAR2; 
function fn_edificio(id_edificio in number) return VARCHAR2;
END PKG_PAGO_DEPTO;

CREATE OR REPLACE PACKAGE BODY PKG_PAGO_DEPTO
IS
function fn_adm_nombre_completo(edificio in number) 
    return VARCHAR2 
as
    nombre_adm VARCHAR2(60);

cursor c_adm is
    select adm.pnombre_adm || ' ' ||adm.snombre_adm || ' ' || adm.appaterno_adm || ' ' || adm.apmaterno_adm as administrador
    from edificio edf join administrador adm on  edf.numrun_adm = adm.numrun_adm  
    where edf.id_edif = edificio;

BEGIN
    
    open c_adm;
    fetch c_adm into nombre_adm;
    
    if c_adm%notfound then
        nombre_adm := 'Administrador no Encontrado';
    end if;
    
    close c_adm;
    
RETURN nombre_adm;
EXCEPTION
WHEN OTHERS THEN
   raise_application_error(-20001,'An error was encountered - '||SQLCODE||' -ERROR- '||SQLERRM);
END;

--select id_edif, f_adm_nombre_completo(id_edif) as Admin from edificio;

/*Función Almacenada que permita obtener el nombre completo del responsable del pago del gasto común*/

function fn_responsable_nombre(depto in number, fecha_cancelacion in date) 
    return VARCHAR2 
as
    nombre_resp VARCHAR2(60);

cursor c_res is
    select rpgc.pnombre_rpgc || ' ' || rpgc.snombre_rpgc || ' ' || rpgc.appaterno_rpgc || ' ' || rpgc.apmaterno_rpgc as responsable
    from responsable_pago_gasto_comun rpgc join gasto_comun gc on rpgc.numrun_rpgc = gc.numrun_rpgc join pago_gasto_comun pgc on gc.nro_depto=pgc.nro_depto
    where pgc.nro_depto = depto and pgc.fecha_cancelacion_pgc = fecha_cancelacion
    order by pgc.fecha_cancelacion_pgc;

BEGIN
    
    open c_res;
    fetch c_res into nombre_resp;
    
    if c_res%notfound then
        nombre_resp := 'Responsable no Encontrado';
    end if;
    
    close c_res;
    
RETURN nombre_resp;
EXCEPTION
WHEN OTHERS THEN
   raise_application_error(-20001,'An error was encountered - '||SQLCODE||' -ERROR- '||SQLERRM);
END;

--select nro_depto, fecha_cancelacion_pgc, f_responsable_nombre(nro_depto, fecha_cancelacion_pgc) resp from pago_gasto_comun order by nro_depto, fecha_cancelacion_pgc desc;

/*Función Almacenada que permita obtener el nombre del edificio*/

function fn_edificio(id_edificio in number) 
    return VARCHAR2 
as
    nombre_edificio VARCHAR2(30);

cursor c_edif is
    select nombre_edif from edificio where id_edif = id_edificio;

BEGIN
    
    open c_edif;
    fetch c_edif into nombre_edificio;
    
    if c_edif%notfound then
        nombre_edificio := 'Edificio no Encontrado';
    end if;
    
    close c_edif;
    
RETURN nombre_edificio;
EXCEPTION
WHEN OTHERS THEN
   raise_application_error(-20001,'An error was encountered - '||SQLCODE||' -ERROR- '||SQLERRM);
END;
END PKG_PAGO_DEPTO;
--select id_edif, f_edificio(id_edif) from edificio;

select id_edif, f_adm_nombre_completo(id_edif),nro_depto, fecha_cancelacion_pgc, f_responsable_nombre(nro_depto, fecha_cancelacion_pgc) resp from edificio join
pago_gasto_comun on f_responsable_nombre = f_adm_nombre_completo;
--order by nro_depto, fecha_cancelacion_pgc desc;

--select * from fn_adm_nombre_completo JOIN fn_responsable on id_edif = nro_depto;

create or replace procedure sp_modificar_pago ( anno_mes gasto_comun_pago_cero.anno_mes_pcgc%TYPE, id_ed gasto_comun_pago_cero.id_edif%type, nom_ed gasto_comun_pago_cero.nombre_edif%TYPE, run_adm gasto_comun_pago_cero.run_administrador%type, nom_adm gasto_comun_pago_cero.nombre_admnistrador%type, nro_dep gasto_comun_pago_cero.nro_depto%type, run_resp gasto_comun_pago_cero.run_responsable_pago_gc%type, nom_resp gasto_comun_pago_cero.run_responsable_pago_gc%type, val_multa gasto_comun_pago_cero.valor_multa_pago_cero%type, obs gasto_comun_pago_cero.observacion%type)
is
begin
update gasto_comun_pago_cero set anno_mes_pcgc = anno_mes, id_edif = id_ed, nombre_edif = nom_ed, run_administrador = run_adm, nombre_admnistrador = nom_adm, nro_depto = nro_dep, run_responsable_pago_gc = run_resp, nombre_responsable_pago_gc = nom_resp, valor_multa_pago_cero = val_multa, observacion = obs
where anno_mes_pcgc = anno_mes;
commit;
dbms_output.put_line('Se actualizo');
exception
when others then
rollback;
dbms_output.put_line('No se actualizo');
end sp_modificar_pago;


