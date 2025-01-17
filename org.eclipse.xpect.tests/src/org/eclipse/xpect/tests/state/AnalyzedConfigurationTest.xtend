/*******************************************************************************
 * Copyright (c) 2012-2017 TypeFox GmbH and itemis AG.
 * This program and the accompanying materials are made
 * available under the terms of the Eclipse Public License 2.0
 * which is available at https://www.eclipse.org/legal/epl-2.0/
 *
 * SPDX-License-Identifier: EPL-2.0
 *
 * Contributors:
 *   Moritz Eysholdt - Initial contribution and API
 *******************************************************************************/

package org.eclipse.xpect.tests.state;

import org.junit.Test

import static org.eclipse.xpect.tests.TestUtil.*
import static org.eclipse.xpect.tests.state.StateTestUtil.*

class AnalyzedConfigurationTest {

	@Test
	def void testSimple() {
		val actual = newAnalyzedConfiguration [
			addFactory(Singleton1);
			addFactory(Singleton2);
			addDefaultValue("MyString1");
			addValue(MyAnnotaion1, "MyString2");
		]
		val expected = '''
			Primary Values {
			    PrimaryValue[@MyAnnotaion1 String Managed[MyString2]]
			    PrimaryValue[StateContainer Managed[null]]
			    PrimaryValue[String Managed[MyString1]]
			}
			Derived Values {
			    org.eclipse.xpect.tests.state.Singleton1 {
			        out DerivedValue[StringBuffer Singleton1.getBuffer()]
			    }
			    org.eclipse.xpect.tests.state.Singleton2 {
			        in PrimaryValue[@MyAnnotaion1 String Managed[MyString2]]
			        out DerivedValue[@Annotation StringBuffer Singleton2.getBuffer()]
			    }
			}
		'''
		assertEquals(expected, actual);
	}

	@Test
	def void testStaticValue() {
		val actual = newAnalyzedConfiguration[
			addFactory(TestData.StaticValueProvider);
		]
		val expected = '''
			Primary Values {
			    PrimaryValue[StateContainer Managed[null]]
			}
			Derived Values {
			    org.eclipse.xpect.tests.state.TestData$StaticValueProvider {
			        out DerivedValue[@Ann String StaticValueProvider.getAnnotatedValue()]
			        out DerivedValue[String StaticValueProvider.getDefaultValue()]
			    }
			}
		'''
		assertEquals(expected, actual);
	}

	@Test
	def void testStaticManaged() {
		val actual = newAnalyzedConfiguration [
			addFactory(TestData.StaticManagedProvider);
		]
		val expected = '''
			Primary Values {
			    PrimaryValue[StateContainer Managed[null]]
			}
			Derived Values {
			    org.eclipse.xpect.tests.state.TestData$StaticManagedProvider {
			        out DerivedValue[@Ann String StaticManagedProvider.getAnnotatedManaged()]
			        out DerivedValue[String StaticManagedProvider.getDefaultManaged()]
			    }
			}
		'''
		assertEquals(expected, actual);
	}

	@Test
	def void testLogginTestDataValue() {
		val actual = newAnalyzedConfiguration[
			addDefaultValue(new LoggingTestData.EventLogger());
			addFactory(LoggingTestData.StaticValueLoggingProvider);
			addFactory(LoggingTestData.DerivedProvider);
		]
		val expected = '''
			Primary Values {
			    PrimaryValue[EventLogger Managed[]]
			    PrimaryValue[StateContainer Managed[null]]
			}
			Derived Values {
			    org.eclipse.xpect.tests.state.LoggingTestData$StaticValueLoggingProvider {
			        in PrimaryValue[EventLogger Managed[]]
			        out DerivedValue[@Ann String StaticValueLoggingProvider.getAnnotatedValue()]
			        out DerivedValue[String StaticValueLoggingProvider.getDefaultValue()]
			    }
			    org.eclipse.xpect.tests.state.LoggingTestData$DerivedProvider {
			        in DerivedValue[@Ann String StaticValueLoggingProvider.getAnnotatedValue()]
			        in DerivedValue[String StaticValueLoggingProvider.getDefaultValue()]
			        in PrimaryValue[EventLogger Managed[]]
			        out DerivedValue[@AnnDerived1 String DerivedProvider.getDerived1()]
			        out DerivedValue[@AnnDerived2 String DerivedProvider.getDerived2()]
			    }
			}
		'''
		assertEquals(expected, actual);
	}

	@Test
	def void testLogginTestDataManaged() {
		val actual = newAnalyzedConfiguration[
			addDefaultValue(new LoggingTestData.EventLogger());
			addFactory(LoggingTestData.StaticManagedLoggingProvider);
			addFactory(LoggingTestData.DerivedProvider);
		]
		val expected = '''
			Primary Values {
			    PrimaryValue[EventLogger Managed[]]
			    PrimaryValue[StateContainer Managed[null]]
			}
			Derived Values {
			    org.eclipse.xpect.tests.state.LoggingTestData$StaticManagedLoggingProvider {
			        in PrimaryValue[EventLogger Managed[]]
			        out DerivedValue[@Ann String StaticManagedLoggingProvider.getAnnotatedManaged()]
			        out DerivedValue[String StaticManagedLoggingProvider.getDefaultManaged()]
			    }
			    org.eclipse.xpect.tests.state.LoggingTestData$DerivedProvider {
			        in DerivedValue[@Ann String StaticManagedLoggingProvider.getAnnotatedManaged()]
			        in DerivedValue[String StaticManagedLoggingProvider.getDefaultManaged()]
			        in PrimaryValue[EventLogger Managed[]]
			        out DerivedValue[@AnnDerived1 String DerivedProvider.getDerived1()]
			        out DerivedValue[@AnnDerived2 String DerivedProvider.getDerived2()]
			    }
			}
		'''
		assertEquals(expected, actual);
	}

	@Test def void multiConstructor1() {
		val actual = newAnalyzedConfiguration[
			addFactory(MultiConstructor);
		]
		val expected = '''
			Primary Values {
			    PrimaryValue[StateContainer Managed[null]]
			}
			Derived Values {
			    org.eclipse.xpect.tests.state.MultiConstructor {
			        out DerivedValue[Object MultiConstructor.get()]
			    }
			    UNRESOLVED org.eclipse.xpect.tests.state.MultiConstructor {
			        in (unresolved class java.lang.String)
			        out DerivedValue[Object MultiConstructor.get()]
			    }
			    UNRESOLVED org.eclipse.xpect.tests.state.MultiConstructor {
			        in (unresolved interface java.lang.CharSequence)
			        out DerivedValue[Object MultiConstructor.get()]
			    }
			}
		'''
		assertEquals(expected, actual);
	}

	@Test def void multiConstructor2() {
		val base = newAnalyzedConfiguration[
			addFactory(MultiConstructor);
		]
		val actual = newAnalyzedConfiguration(base) [
			addDefaultValue(String, "myString")
		]
		val expected = '''
			Primary Values {
			    PrimaryValue[StateContainer Managed[null]]
			    PrimaryValue[String Managed[myString]]
			}
			Derived Values {
			    org.eclipse.xpect.tests.state.MultiConstructor {
			        in PrimaryValue[String Managed[myString]]
			        out DerivedValue[Object MultiConstructor.get()]
			    }
			}
			Primary Values {
			    PrimaryValue[StateContainer Managed[null]]
			}
			Derived Values {
			    org.eclipse.xpect.tests.state.MultiConstructor {
			        out DerivedValue[Object MultiConstructor.get()]
			    }
			    UNRESOLVED org.eclipse.xpect.tests.state.MultiConstructor {
			        in (unresolved class java.lang.String)
			        out DerivedValue[Object MultiConstructor.get()]
			    }
			    UNRESOLVED org.eclipse.xpect.tests.state.MultiConstructor {
			        in (unresolved interface java.lang.CharSequence)
			        out DerivedValue[Object MultiConstructor.get()]
			    }
			}
		'''
		assertEquals(expected, actual);
	}

	@Test def void multiConstructor3() {
		val base = newAnalyzedConfiguration[
			addFactory(MultiConstructor);
		]
		val actual = newAnalyzedConfiguration(base) [
			addDefaultValue(CharSequence, "mySequence")
		]
		val expected = '''
			Primary Values {
			    PrimaryValue[CharSequence Managed[mySequence]]
			    PrimaryValue[StateContainer Managed[null]]
			}
			Derived Values {
			    org.eclipse.xpect.tests.state.MultiConstructor {
			        in PrimaryValue[CharSequence Managed[mySequence]]
			        out DerivedValue[Object MultiConstructor.get()]
			    }
			    UNRESOLVED org.eclipse.xpect.tests.state.MultiConstructor {
			        in (unresolved class java.lang.String)
			        out DerivedValue[Object MultiConstructor.get()]
			    }
			}
			Primary Values {
			    PrimaryValue[StateContainer Managed[null]]
			}
			Derived Values {
			    org.eclipse.xpect.tests.state.MultiConstructor {
			        out DerivedValue[Object MultiConstructor.get()]
			    }
			    UNRESOLVED org.eclipse.xpect.tests.state.MultiConstructor {
			        in (unresolved class java.lang.String)
			        out DerivedValue[Object MultiConstructor.get()]
			    }
			    UNRESOLVED org.eclipse.xpect.tests.state.MultiConstructor {
			        in (unresolved interface java.lang.CharSequence)
			        out DerivedValue[Object MultiConstructor.get()]
			    }
			}
		'''
		assertEquals(expected, actual);
	}

	@Test def void typeParam() {
		val actual = newAnalyzedConfiguration[
			addDefaultValue(Class, String)
			addFactory(TypeParam);
		]
		val expected = '''
			Primary Values {
			    PrimaryValue[Class Managed[class java.lang.String]]
			    PrimaryValue[StateContainer Managed[null]]
			}
			Derived Values {
			    org.eclipse.xpect.tests.state.TypeParam {
			        in PrimaryValue[Class Managed[class java.lang.String]]
			        out DerivedValue[String TypeParam.get()]
			    }
			}
		'''
		assertEquals(expected, actual);
	}

	@Test def void typeParamUnresolved() {
		val actual = newAnalyzedConfiguration[
			addFactory(TypeParam);
		]
		val expected = '''
			Primary Values {
			    PrimaryValue[StateContainer Managed[null]]
			}
			Derived Values {
			    UNRESOLVED org.eclipse.xpect.tests.state.TypeParam {
			        in (unresolved class java.lang.Class)
			        out DerivedValue[(unresolved) TypeParam.get()]
			    }
			}
		'''
		assertEquals(expected, actual);
	}

}
