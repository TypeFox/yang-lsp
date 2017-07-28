package io.typefox.yang.tests.fomatting

import com.google.common.io.Files
import io.typefox.yang.tests.AbstractYangLSPTest
import java.io.File
import java.util.Collection
import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor
import org.junit.Test
import org.junit.runner.RunWith
import org.junit.runners.Parameterized
import org.junit.runners.Parameterized.Parameters
import com.google.common.base.Charsets
import org.junit.ComparisonFailure

@FinalFieldsConstructor
@RunWith(Parameterized)
class FormattingTest extends AbstractYangLSPTest {
    
    @Parameters(name= "{0}")
    static def Collection<Object[]> getFiles() {
        val params = newArrayList
        scan(new File("./src/test/resources/good")) [
            val arr = <Object>newArrayOfSize(1)
            arr.set(0, it)
            params.add(arr)
        ]
        return params
    }
    
    static def void scan(File directory, (File)=>void acceptor) {
        if (directory.isDirectory) {
            directory.listFiles.filter[it.isFile].forEach[acceptor.apply(it)]
        }
    }
    
    val File file 
    
    @Test def void testFormatting_ignoring_comparision_failures() {
        val content = Files.toString(file, Charsets.UTF_8)
        try {
            testFormatting[
                model = content
                expectedText = content
            ]
        } catch(ComparisonFailure ignored) {
        }
    }
    
}