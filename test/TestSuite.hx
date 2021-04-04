import massive.munit.TestSuite;
import com.bitdecay.analytics.SessionTest;
import com.bitdecay.net.influx.InfluxDBTest;

/**
 * Auto generated Test Suite for MassiveUnit.
 * Refer to munit command line tool for more information (haxelib run munit)
 */
class TestSuite extends massive.munit.TestSuite {
	public function new() {
		super();

		add(com.bitdecay.analytics.SessionTest);
		add(com.bitdecay.net.influx.InfluxDBTest);
	}
}
