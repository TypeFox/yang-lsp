package io.typefox.yang.tests.settings;

import static org.junit.Assert.assertEquals;

import java.nio.file.Path;

import org.junit.Test;

import io.typefox.yang.settings.JsonFileBasedPreferenceValues;

public class JsonFileBasedPreferenceValuesTest {

	@Test
	public void testIndentationParseTest() {
		String settingsJson = "{\n" + "   \"indentation\": \"  \"\n" + "}";
		JsonFileBasedPreferenceValues fileBasedPreferenceValues = new JsonFileBasedPreferenceValues(null, null) {
			@Override
			protected byte[] readBytes(Path path) {
				return settingsJson.getBytes();
			}
		};
		fileBasedPreferenceValues.read();
		assertEquals("  ", fileBasedPreferenceValues.getValues().get("indentation"));
	}
}
