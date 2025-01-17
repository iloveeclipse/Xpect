/*******************************************************************************
 * Copyright (c) 2011 itemis AG (http://www.itemis.eu) and others.
 * This program and the accompanying materials are made
 * available under the terms of the Eclipse Public License 2.0
 * which is available at https://www.eclipse.org/legal/epl-2.0/
 *
 * SPDX-License-Identifier: EPL-2.0
 *******************************************************************************/
package org.eclipse.xtext.example.domainmodel;


/**
 * Initialization support for running Xtext languages 
 * without equinox extension registry
 */
public class DomainmodelStandaloneSetup extends DomainmodelStandaloneSetupGenerated{

	public static void doSetup() {
		new DomainmodelStandaloneSetup().createInjectorAndDoEMFRegistration();
	}
}

