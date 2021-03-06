/*
 * generated by Xtext 2.10.0
 */
package org.eclipse.gemoc.validation

import org.eclipse.gemoc.dsl.Dsl
import org.eclipse.gemoc.dsl.DslPackage
import org.eclipse.gemoc.dsl.Entry
import org.eclipse.xtext.validation.Check
import org.eclipse.core.runtime.IConfigurationElement
import java.util.ArrayList
import org.eclipse.gemoc.xdsmlframework.api.extensions.metaprog.Message
import org.eclipse.gemoc.xdsmlframework.api.extensions.metaprog.Severity
import org.eclipse.gemoc.xdsmlframework.api.extensions.metaprog.LanguageComponentHelper
import org.eclipse.gemoc.xdsmlframework.api.extensions.metaprog.ILanguageComponentValidator

/**
 * This class contains custom validation rules. 
 *
 * See https://www.eclipse.org/Xtext/documentation/303_runtime_concepts.html#validation
 */
class DslValidator extends AbstractDslValidator {
	
	public static val MISSING_NAME = 'missingName'
	public static val MISSING_KEY = 'missingKey'
	public static val DUPLICATEKEY = 'duplicateKey'
	
	
	public val IConfigurationElement[] exts = org.eclipse.core.runtime.Platform.getExtensionRegistry().getConfigurationElementsFor("org.eclipse.gemoc.gemoc_language_workbench.metaprog")
	public val LanguageComponentHelper languageHelper = new LanguageComponentHelper();
	public var ArrayList<IConfigurationElement> keys = new ArrayList<IConfigurationElement>()
	public var String metaprog
		
	//public var IRuleProvider providedValidator

	@Check
	def checkDSLHasName(Dsl dsl) {
		if (dsl.name.isEmpty) {
			error('Missing an entry "name"', 
					DslPackage.Literals.DSL__NAME,
					MISSING_NAME)
		}
	}
	
	@Check
	def checkDuplicateKeys(Entry entry) {
		val dsl = entry.eContainer as Dsl
		if (!dsl.entries.filter[e | e.key == entry.key].forall[e | e === entry]) {
			error('Duplicate key "'+entry.key+'"', 
					DslPackage.Literals.ENTRY__KEY,
					DUPLICATEKEY)
		}
	}
		
	// Performs checks provided by the required metaprogramming approach's validator for each entry in the dsl file
	@Check
	def checkForEntry(Entry entry) {
		
		for(IConfigurationElement key : keys) {
			val ILanguageComponentValidator rule = key.createExecutableExtension("validationRule") as ILanguageComponentValidator
			var message = rule.validate(entry)
			
			switch message.getSeverity() {
				
				case Severity.ERROR :	error(message.getContent(),
														DslPackage.Literals.ENTRY__VALUE
														)
				case Severity.WARNING :	warning(message.getContent(),
														DslPackage.Literals.ENTRY__VALUE
													)
				case Severity.INFO :	info(message.getContent(),
														DslPackage.Literals.ENTRY__VALUE
													)
				case Severity.DEFAULT : message = new Message()
				
				default : print("Unknown severity")
			}
		}

	}
	
	@Check
	def checkForApproachEntry(Dsl dsl) {
		if(dsl.getEntries().filter[e | e.key == "metaprog"].isEmpty) {
			warning("Missing \"metaprog\" entry to define the metaprogramming approach used", DslPackage.Literals.DSL__NAME)
		}
	}
	
	@Check
	def checkApproach(Entry entry) {
		
		var ArrayList<String> approachesList = new ArrayList<String>()
		
		if("metaprog".matches(entry.key)){
				metaprog = entry.value
				
				for(IConfigurationElement elem : exts){
					approachesList.add(elem.getAttribute("name"))
				}
				
				if(!approachesList.contains(metaprog)){
				error("Unknown metaprogramming approach", DslPackage.Literals.ENTRY__VALUE)
				}
			}
	}
	
	
	@Check
	def checkMissingKeys(Dsl dsl){
		
		var ArrayList<String> dslKeys = new ArrayList<String>()
		for(Entry entry : dsl.getEntries){
			dslKeys.add(entry.getKey)
		}
		keys = languageHelper.getFullApproachKeys(metaprog)
		
		for(IConfigurationElement elem : keys){
			var name = elem.getAttribute("name")
			if((!dslKeys.contains(name)) && ("false".matches(elem.getAttribute("optional")))){
				error("Missing entry " + name + " in the dsl file.", DslPackage.Literals.DSL__NAME, MISSING_KEY)
			}
			
		}
	}

}
