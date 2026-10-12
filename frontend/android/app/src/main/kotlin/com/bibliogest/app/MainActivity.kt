package com.bibliogest.app

import android.content.Intent
import android.net.Uri
import android.provider.Settings
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

/**
 * Actividad principal. Ademas de Flutter, expone lo minimo que hace falta para
 * actualizar la app desde dentro: una carpeta de descargas propia y el
 * instalador de paquetes de Android.
 */
class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CANAL).setMethodCallHandler { llamada, resultado ->
            when (llamada.method) {
                "carpeta" -> resultado.success(carpetaDescargas().absolutePath)
                "puedeInstalar" -> resultado.success(packageManager.canRequestPackageInstalls())
                "pedirPermisoInstalar" -> {
                    // Pantalla de Ajustes donde el usuario autoriza a BiblioGest a instalar apps.
                    val intent = Intent(
                        Settings.ACTION_MANAGE_UNKNOWN_APP_SOURCES,
                        Uri.parse("package:$packageName"),
                    ).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    startActivity(intent)
                    resultado.success(null)
                }
                "instalar" -> {
                    val ruta = llamada.argument<String>("ruta")
                    if (ruta == null) {
                        resultado.error("ruta", "Falta la ruta del archivo", null)
                    } else {
                        instalar(File(ruta))
                        resultado.success(null)
                    }
                }
                else -> resultado.notImplemented()
            }
        }
    }

    /** Carpeta (dentro de la cache de la app) donde se guardan las actualizaciones descargadas. */
    private fun carpetaDescargas(): File {
        val carpeta = File(cacheDir, "actualizaciones")
        carpeta.mkdirs()
        return carpeta
    }

    /** Abre el instalador del sistema con el APK descargado. Android pide confirmar al usuario. */
    private fun instalar(apk: File) {
        val uri = FileProvider.getUriForFile(this, "$packageName.fileprovider", apk)
        val intent = Intent(Intent.ACTION_VIEW)
            .setDataAndType(uri, "application/vnd.android.package-archive")
            .addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION or Intent.FLAG_ACTIVITY_NEW_TASK)
        startActivity(intent)
    }

    companion object {
        private const val CANAL = "com.bibliogest.app/actualizaciones"
    }
}
