package com.tbl.makstore

import android.os.Environment
import android.os.StatFs
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.util.Log
import android.content.Intent
import android.net.Uri
import android.widget.Toast

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.tbl.makstore/storage"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getStorageInfo") {
                try {
                    val path = Environment.getDataDirectory()
                    val stat = StatFs(path.path)
                    val blockSize = stat.blockSizeLong
                    val totalBlocks = stat.blockCountLong
                    val availableBlocks = stat.availableBlocksLong

                    val totalSpace = totalBlocks * blockSize
                    val freeSpace = availableBlocks * blockSize

                    val storageMap = mapOf(
                        "totalSpace" to totalSpace,
                        "freeSpace" to freeSpace
                    )
                    result.success(storageMap)
                } catch (e: Exception) {
                    result.error("STORAGE_ERROR", "Failed to get store info: ${e.message}", null)
                }
            } else if (call.method == "uninstallApp") {
                val packageName = call.argument<String>("packageName")
                Log.d("UMakstore", "Uninstalling package: $packageName")
                if (packageName != null) {
                    try {
                        Toast.makeText(this, "Native: Attempting to uninstall $packageName", Toast.LENGTH_SHORT).show()
                        val intent = Intent(Intent.ACTION_DELETE)
                        intent.data = Uri.parse("package:$packageName")
                        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        startActivity(intent)
                        Log.d("UMakstore", "Uninstall intent started successfully")
                        result.success(true)
                    } catch (e: Exception) {
                        Log.e("UMakstore", "Uninstall error: ${e.message}")
                        result.error("UNINSTALL_ERROR", e.message, null)
                    }
                } else {
                    result.error("INVALID_ARGUMENT", "Package name is null", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }
}
