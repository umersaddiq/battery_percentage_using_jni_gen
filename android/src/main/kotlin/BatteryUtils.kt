import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.BatteryManager
import androidx.annotation.Keep
import kotlinx.coroutines.channels.awaitClose
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.callbackFlow

@Keep
interface BatteryCallback {
    fun onBatteryPercentageChanged(percentage: Int)
}

@Keep
class BatteryUtils(private val context: Context) {
    private var batteryReceiver: BroadcastReceiver? = null

    fun sum(a: Int, b: Int): Int {
        return a + b
    }
    
    fun stopBatteryPercentageStream() {
        batteryReceiver?.let {
            try {
                context.unregisterReceiver(it)
            } catch (e: IllegalArgumentException) {
            }
            batteryReceiver = null
        }
    }

    fun startBatteryPercentageStream(callback: BatteryCallback) {
        stopBatteryPercentageStream();
        batteryReceiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context?, intent: Intent?) {
                intent?.let {
                    val level = it.getIntExtra(BatteryManager.EXTRA_LEVEL, -1)
                    val scale = it.getIntExtra(BatteryManager.EXTRA_SCALE, -1)
                    if (level != -1 && scale != -1) {
                        val percentage = (level * 100) / scale
                        callback.onBatteryPercentageChanged(percentage)
                    }
                }
            }
        }
        
        val intentFilter = IntentFilter(Intent.ACTION_BATTERY_CHANGED)
        context.registerReceiver(batteryReceiver, intentFilter)
        
        callback.onBatteryPercentageChanged(getBatteryPercentage())
    }

    fun getBatteryPercentage(): Int {
        val batteryManager = context.getSystemService(Context.BATTERY_SERVICE) as BatteryManager
        return batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY)
    }

    fun getBatteryPercentageLegacy(): Int {
        val intentFilter = IntentFilter(Intent.ACTION_BATTERY_CHANGED)
        val batteryStatus = context.registerReceiver(null, intentFilter)
        val level = batteryStatus?.getIntExtra("level", -1) ?: -1
        val scale = batteryStatus?.getIntExtra("scale", -1) ?: -1

        return if (level != -1 && scale != -1) {
            (level * 100) / scale
        } else {
            -1
        }
    }
}
