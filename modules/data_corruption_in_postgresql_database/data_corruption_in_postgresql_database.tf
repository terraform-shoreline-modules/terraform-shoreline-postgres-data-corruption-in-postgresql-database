resource "shoreline_notebook" "data_corruption_in_postgresql_database" {
  name       = "data_corruption_in_postgresql_database"
  data       = file("${path.module}/data/data_corruption_in_postgresql_database.json")
  depends_on = [shoreline_action.invoke_restore_postgresql_database,shoreline_action.invoke_repair_db_table]
}

resource "shoreline_file" "restore_postgresql_database" {
  name             = "restore_postgresql_database"
  input_file       = "${path.module}/data/restore_postgresql_database.sh"
  md5              = filemd5("${path.module}/data/restore_postgresql_database.sh")
  description      = "Restore data from a backup: If you have a recent backup of the database, you can restore the data from it. However, this may cause some data loss if the backup was not taken right before the corruption occurred."
  destination_path = "/tmp/restore_postgresql_database.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "repair_db_table" {
  name             = "repair_db_table"
  input_file       = "${path.module}/data/repair_db_table.sh"
  md5              = filemd5("${path.module}/data/repair_db_table.sh")
  description      = "Repair corrupted tables: If only a few tables in the database are corrupted, you can try to repair them using the PostgreSQL tool called pg_resetxlog or pg_resetwal."
  destination_path = "/tmp/repair_db_table.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_action" "invoke_restore_postgresql_database" {
  name        = "invoke_restore_postgresql_database"
  description = "Restore data from a backup: If you have a recent backup of the database, you can restore the data from it. However, this may cause some data loss if the backup was not taken right before the corruption occurred."
  command     = "`chmod +x /tmp/restore_postgresql_database.sh && /tmp/restore_postgresql_database.sh`"
  params      = ["BACKUP_FILE","DB_USERNAME","DB_PASSWORD","DB_NAME"]
  file_deps   = ["restore_postgresql_database"]
  enabled     = true
  depends_on  = [shoreline_file.restore_postgresql_database]
}

resource "shoreline_action" "invoke_repair_db_table" {
  name        = "invoke_repair_db_table"
  description = "Repair corrupted tables: If only a few tables in the database are corrupted, you can try to repair them using the PostgreSQL tool called pg_resetxlog or pg_resetwal."
  command     = "`chmod +x /tmp/repair_db_table.sh && /tmp/repair_db_table.sh`"
  params      = ["TABLE_NAME","VERSION","DB_NAME"]
  file_deps   = ["repair_db_table"]
  enabled     = true
  depends_on  = [shoreline_file.repair_db_table]
}

