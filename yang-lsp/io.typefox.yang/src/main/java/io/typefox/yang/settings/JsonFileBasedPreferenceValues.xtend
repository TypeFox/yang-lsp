package io.typefox.yang.settings

import com.google.gson.JsonObject
import com.google.gson.JsonPrimitive
import com.google.gson.internal.Streams
import com.google.gson.stream.JsonReader
import java.io.BufferedReader
import java.io.ByteArrayInputStream
import java.io.InputStreamReader
import java.nio.file.Files
import java.nio.file.NoSuchFileException
import java.nio.file.Path
import java.nio.file.attribute.FileTime
import org.eclipse.xtext.preferences.IPreferenceValues
import org.eclipse.xtext.preferences.MapBasedPreferenceValues
import org.eclipse.xtext.util.internal.Log

@Log
class JsonFileBasedPreferenceValues extends MapBasedPreferenceValues {
	
	val Path path
	FileTime lastModification = null
	
	new(Path path, IPreferenceValues delegate) {
		super(delegate, newHashMap)
		this.path = path
		checkUpToDate
	}
	
	/**
	 * reloads the preferences from disk if the file has changed.
	 */
	public def void checkUpToDate() {
		val d = this.delegate
		if (d instanceof JsonFileBasedPreferenceValues) {
			d.checkUpToDate
		}
		try {
			val localLastMod = Files.getLastModifiedTime(path)
			if (localLastMod != lastModification) {
				lastModification = localLastMod
				read()
			}
		} catch (Exception e) {
			if (!(e instanceof NoSuchFileException)) {
				LOG.error("Error reading settings '"+path+"' : "+e.message)
			} else {
				lastModification = null
			}
			clear()
			return
		}
	}
	
	def void read() {
		clear()
		val reader = new JsonReader(new BufferedReader(new InputStreamReader(new ByteArrayInputStream(Files.readAllBytes(path)))))
		reader.lenient = true
		val object = Streams.parse(reader) as JsonObject
		internalFillMap(null, object)
	}
	
	private def void internalFillMap(String prefix, JsonObject object) {
		for (entry : object.entrySet) {
			switch v : entry.value {
				JsonObject : 
					internalFillMap(entry.key, entry.value as JsonObject)
				JsonPrimitive : {
					val key = if (prefix !== null) {
						prefix + "." + entry.key
					} else {
						entry.key
					}
					this.put(key, v.asString.toString)				
				} 
			}
		}
	}
	
}