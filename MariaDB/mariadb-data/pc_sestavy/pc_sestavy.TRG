TYPE=TRIGGERS
triggers='CREATE DEFINER=`root`@`%` TRIGGER tri_pc_sestavy_after_update\n    AFTER UPDATE ON pc_sestavy\n    FOR EACH ROW\n	    BEGIN\n            IF(OLD.id_ses != NEW.id_ses) THEN\n                INSERT INTO pc_sestavy_zmeny VALUES(id_zme, OLD.id_ses, OLD.id_ses, NEW.id_ses , \'ID sestavy\', NOW(), USER());\n            END IF;\n                 IF(OLD.nazev != NEW.nazev) THEN\n                INSERT INTO pc_sestavy_zmeny VALUES(id_zme, OLD.id_ses, OLD.nazev, NEW.nazev , \'Název\', NOW(), USER());\n            END IF;\n                 IF(OLD.cena != NEW.cena) THEN\n                INSERT INTO pc_sestavy_zmeny VALUES(id_zme, OLD.id_ses, OLD.cena, NEW.cena , \'Cena\', NOW(), USER());\n            END IF;\n                 IF(OLD.id_cpu != NEW.id_cpu) THEN\n                INSERT INTO pc_sestavy_zmeny VALUES(id_zme, OLD.id_ses, OLD.id_cpu, NEW.id_cpu, \'ID Procesoru\', NOW(), USER());  \n            END IF;\n                 IF(OLD.id_zak != NEW.id_zak) THEN\n                INSERT INTO pc_sestavy_zmeny VALUES(id_zme, OLD.id_ses, OLD.id_zak, NEW.id_zak , \'ID Základní desky\', NOW(), USER());\n            END IF;\n                 IF(OLD.id_skr != NEW.id_skr) THEN\n                INSERT INTO pc_sestavy_zmeny VALUES(id_zme, OLD.id_ses, OLD.id_skr, NEW.id_skr , \'ID Skříně\', NOW(), USER());\n            END IF;\n	END'
sql_modes=1411383296
definers='root@%'
client_cs_names='utf8mb4'
connection_cl_names='utf8mb4_unicode_ci'
db_cl_names='utf8mb4_general_ci'
created=1736254625985491
