/*******************************************************************************
 * Copyright (c) 2017 Inria and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     Inria - initial API and implementation
 *******************************************************************************/
package org.eclipse.gemoc.commons.eclipse.ui;

import org.eclipse.ui.PlatformUI;
import org.eclipse.ui.wizards.IWizardDescriptor;

public class WizardFinder {

	static public IWizardDescriptor findNewWizardDescriptor(String wizardId)
	{
		return PlatformUI
				.getWorkbench()
				.getNewWizardRegistry()
				.findWizard(wizardId);
	}
	
}
