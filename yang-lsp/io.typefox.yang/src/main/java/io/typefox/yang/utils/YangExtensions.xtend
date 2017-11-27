package io.typefox.yang.utils

import com.google.inject.Singleton
import io.typefox.yang.yang.AbstractModule
import io.typefox.yang.yang.BelongsTo
import io.typefox.yang.yang.Import
import io.typefox.yang.yang.Module
import io.typefox.yang.yang.Prefix
import io.typefox.yang.yang.Statement
import io.typefox.yang.yang.Submodule
import io.typefox.yang.yang.YangVersion
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.EcoreUtil2

import static extension org.eclipse.xtext.EcoreUtil2.getContainerOfType

/**
 * Convenient extension methods for the YANG language.
 * 
 * @author akos.kitta 
 */
@Singleton
class YangExtensions {

	/**
	 * The {@code 1.0} YANG version.
	 */
	public static val YANG_1 = "1";

	/**
	 * The {@code 1.1} YANG version.
	 */
	public static val YANG_1_1 = "1.1";

	/**
	 * Returns with the YANG version of the module where the AST node element is contained.
	 * <p>
	 * Returns with version {@code 1} if the container module does not declare the version or the version equals
	 * with {@code 1}.
	 * <p>
	 * Returns with {@code 1.1} if the container module has declared YANG version, and that equals to {@code 1.1},
	 * otherwise returns with {@code null}. Also returns with {@code null}, if the argument is not contained in a module.
	 */
	def getYangVersion(EObject it) {
		val module = getContainerOfType(AbstractModule);
		if (module === null) {
			return null;
		}
		val version = module.firstSubstatementsOfType(YangVersion)?.yangVersion;
		if (null === version || YANG_1 == version) {
			return YANG_1;
		}
		return if(YANG_1_1 == version) YANG_1_1 else null;
	}

	/**
	 * Returns with all sub-statements of a given type for the statement argument.
	 */
	def <S extends Statement> substatementsOfType(Statement it, Class<? extends S> clazz) {
		return substatements.filter(clazz);
	}
	
	/**
	 * Returns with the first sub-statement of a given type for the statement argument or {@code null}.
	 */
	def <S extends Statement> firstSubstatementsOfType(Statement it, Class<? extends S> clazz) {
		return substatementsOfType(clazz).head;
	}
	
	/**
	 * Returns with the last sub-statement of a given type for the statement argument or {@code null}.
	 */
	def <S extends Statement> lastSubstatementsOfType(Statement it, Class<? extends S> clazz) {
		return substatementsOfType(clazz).last;
	}

	/**
	 * Returns the main module this element belongs to
	 * Returns the containing module, or the belongs-to module of this element is contained in a submodule.
	 */	
	def Module getMainModule(EObject obj) {
		val module = EcoreUtil2.getContainerOfType(obj, AbstractModule) 
		switch module {
			Submodule: 
				return module.substatements.filter(BelongsTo).head?.module
			Module: 
				return module
			default:
				return null 
		}
	}
	
	/**
	 * Returns the prefix of an element
	 */
	def dispatch String getPrefix(Module it) {
		substatements.filter(Prefix).head?.prefix
	}
	def dispatch String getPrefix(Submodule it) {
		substatements.filter(BelongsTo).head?.prefix
	}
	def dispatch String getPrefix(BelongsTo it) {
		substatements.filter(Prefix).head?.prefix
	}
	def dispatch String getPrefix(Import it) {
		substatements.filter(Prefix).head?.prefix
	}
}
