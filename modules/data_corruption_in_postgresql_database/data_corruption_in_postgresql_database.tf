resource "shoreline_notebook" "data_corruption_in_postgresql_database" {
  name       = "data_corruption_in_postgresql_database"
  data       = file("${path.module}/data/data_corruption_in_postgresql_database.json")
  depends_on = [shoreline_action.invoke_restore_database,shoreline_action.invoke_reset_table]
}

resource "shoreline_file" "restore_database" {
  name             = "restore_database"
  input_file       = "${path.module}/data/restore_database.sh"
  md5              = filemd5("${path.module}/data/restore_database.sh")
  description      = "Restore data from a backup: If you have a recent backup of the database, you can restore the data from it. However, this may cause some data loss if the backup was not taken right before the corruption occurred."
  destination_path = "/tmp/restore_database.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "reset_table" {
  name             = "reset_table"
  input_file       = "${path.module}/data/reset_table.sh"
  md5              = filemd5("${path.module}/data/reset_table.sh")
  description      = "Repair corrupted tables: If only a few tables in the database are corrupted, you can try to repair them using the PostgreSQL tool called pg_resetxlog or pg_resetwal."
  destination_path = "/tmp/reset_table.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_action" "invoke_restore_database" {
  name        = "invoke_restore_database"
  description = "Restore data from a backup: If you have a recent backup of the database, you can restore the data from it. However, this may cause some data loss if the backup was not taken right before the corruption occurred."
  command     = "`chmod +x /tmp/restore_database.sh && /tmp/restore_database.sh`"
  params      = ["DB_NAME","DB_PASSWORD","DB_USERNAME","BACKUP_FILE"]
  file_deps   = ["restore_database"]
  enabled     = true
  depends_on  = [shoreline_file.restore_database]
}

resource "shoreline_action" "invoke_reset_table" {
  name        = "invoke_reset_table"
  description = "Repair corrupted tables: If only a few tables in the database are corrupted, you can try to repair them using the PostgreSQL tool called pg_resetxlog or pg_resetwal."
  command     = "`chmod +x /tmp/reset_table.sh && /tmp/reset_table.sh`"
  params      = ["VERSION","TABLE_NAME","DB_NAME"]
  file_deps   = ["reset_table"]
  enabled     = true
  depends_on  = [shoreline_file.reset_table]
}

