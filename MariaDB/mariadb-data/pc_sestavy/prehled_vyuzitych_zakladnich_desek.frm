TYPE=VIEW
query=select `pc_sestavy`.`zakladni_desky`.`nazev` AS `Název zakladní desky`,`pc_sestavy`.`cipove_sady`.`oznaceni` AS `Čipset`,`pc_sestavy`.`vyrobci`.`nazev` AS `Název výrobce`,count(0) AS `Počet využích desek` from ((`pc_sestavy`.`cipove_sady` left join (`pc_sestavy`.`zakladni_desky` left join `pc_sestavy`.`pc_sestavy` on(`pc_sestavy`.`zakladni_desky`.`id_zak` = `pc_sestavy`.`pc_sestavy`.`id_zak`)) on(`pc_sestavy`.`zakladni_desky`.`id_cip` = `pc_sestavy`.`cipove_sady`.`id_cip`)) join `pc_sestavy`.`vyrobci` on(`pc_sestavy`.`zakladni_desky`.`id_vyr` = `pc_sestavy`.`vyrobci`.`id_vyr`)) group by `pc_sestavy`.`zakladni_desky`.`nazev`
md5=d8964aeb9d5acde780f9f5966466e949
updatable=0
algorithm=0
definer_user=root
definer_host=%
suid=2
with_check_option=0
timestamp=0001736254177736636
create-version=2
source=SELECT zakladni_desky.nazev AS "Název zakladní desky", \n    cipove_sady.oznaceni AS "Čipset", vyrobci.nazev AS "Název výrobce" ,COUNT(*) AS "Počet využích desek" \n    FROM zakladni_desky LEFT JOIN pc_sestavy ON zakladni_desky.id_zak = pc_sestavy.id_zak \n    RIGHT JOIN cipove_sady ON zakladni_desky.id_cip = cipove_sady.id_cip  \n    INNER JOIN vyrobci ON zakladni_desky.id_vyr = vyrobci.id_vyr GROUP BY zakladni_desky.nazev
client_cs_name=utf8mb4
connection_cl_name=utf8mb4_unicode_ci
view_body_utf8=select `pc_sestavy`.`zakladni_desky`.`nazev` AS `Název zakladní desky`,`pc_sestavy`.`cipove_sady`.`oznaceni` AS `Čipset`,`pc_sestavy`.`vyrobci`.`nazev` AS `Název výrobce`,count(0) AS `Počet využích desek` from ((`pc_sestavy`.`cipove_sady` left join (`pc_sestavy`.`zakladni_desky` left join `pc_sestavy`.`pc_sestavy` on(`pc_sestavy`.`zakladni_desky`.`id_zak` = `pc_sestavy`.`pc_sestavy`.`id_zak`)) on(`pc_sestavy`.`zakladni_desky`.`id_cip` = `pc_sestavy`.`cipove_sady`.`id_cip`)) join `pc_sestavy`.`vyrobci` on(`pc_sestavy`.`zakladni_desky`.`id_vyr` = `pc_sestavy`.`vyrobci`.`id_vyr`)) group by `pc_sestavy`.`zakladni_desky`.`nazev`
mariadb-version=110602
