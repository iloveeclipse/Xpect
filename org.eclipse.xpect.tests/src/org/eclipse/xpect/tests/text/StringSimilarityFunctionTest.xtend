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

package org.eclipse.xpect.tests.text

import org.junit.Test
import static org.junit.Assert.*
import org.eclipse.xpect.util.IDifferencer.ISimilarityFunction
import org.eclipse.xpect.text.StringEndsSimilarityFunction
import java.util.Locale

class StringSimilarityFunctionTest {
	@Test def void testEqual() {
		assertTrue(ISimilarityFunction.EQUAL == similarity("abc", "abc"))
	}

	@Test def void testUnequal() {
		assertTrue(ISimilarityFunction.UPPER_SIMILARITY_BOUND == similarity("", ""))
		assertTrue(ISimilarityFunction.UPPER_SIMILARITY_BOUND == similarity(null, null))
	}

	@Test def void testSimilarBeginning() {
		val data = newArrayList()
		data += "aaaaaaaaaa" -> "aaaaaaaaaa"
		data += "aaaaaaaaaa" -> "aaaaaaaaa-"
		data += "aaaaaaaaaa" -> "aaaaaaaa--"
		data += "aaaaaaaaaa" -> "aaaaaaa---"
		data += "aaaaaaaaaa" -> "aaaaaa----"
		data += "aaaaaaaaaa" -> "aaaaa-----"
		data += "aaaaaaaaaa" -> "aaaa------"
		data += "aaaaaaaaaa" -> "aaa-------"
		data += "aaaaaaaaaa" -> "aa--------"
		data += "aaaaaaaaaa" -> "a---------"
		data += "aaaaaaaaaa" -> "----------"

		val expected = '''
			aaaaaaaaaa <> aaaaaaaaaa --> 0.00
			aaaaaaaaaa <> aaaaaaaaa- --> 0.25
			aaaaaaaaaa <> aaaaaaaa-- --> 0.50
			aaaaaaaaaa <> aaaaaaa--- --> 0.75
			aaaaaaaaaa <> aaaaaa---- --> 1.00
			aaaaaaaaaa <> aaaaa----- --> 1.00
			aaaaaaaaaa <> aaaa------ --> 1.00
			aaaaaaaaaa <> aaa------- --> 1.00
			aaaaaaaaaa <> aa-------- --> 1.00
			aaaaaaaaaa <> a--------- --> 1.00
			aaaaaaaaaa <> ---------- --> 1.00
		'''

		assertEquals(expected.trim, similarityStr(data))
	}

	@Test def void testSimilarEnd() {
		val data = newArrayList()
		data += "aaaaaaaaaa" -> "aaaaaaaaaa"
		data += "aaaaaaaaaa" -> "-aaaaaaaaa"
		data += "aaaaaaaaaa" -> "--aaaaaaaa"
		data += "aaaaaaaaaa" -> "---aaaaaaa"
		data += "aaaaaaaaaa" -> "----aaaaaa"
		data += "aaaaaaaaaa" -> "-----aaaaa"
		data += "aaaaaaaaaa" -> "------aaaa"
		data += "aaaaaaaaaa" -> "-------aaa"
		data += "aaaaaaaaaa" -> "--------aa"
		data += "aaaaaaaaaa" -> "---------a"
		data += "aaaaaaaaaa" -> "----------"

		val expected = '''
			aaaaaaaaaa <> aaaaaaaaaa --> 0.00
			aaaaaaaaaa <> -aaaaaaaaa --> 0.25
			aaaaaaaaaa <> --aaaaaaaa --> 0.50
			aaaaaaaaaa <> ---aaaaaaa --> 0.75
			aaaaaaaaaa <> ----aaaaaa --> 1.00
			aaaaaaaaaa <> -----aaaaa --> 1.00
			aaaaaaaaaa <> ------aaaa --> 1.00
			aaaaaaaaaa <> -------aaa --> 1.00
			aaaaaaaaaa <> --------aa --> 1.00
			aaaaaaaaaa <> ---------a --> 1.00
			aaaaaaaaaa <> ---------- --> 1.00
		'''

		assertEquals(expected.trim, similarityStr(data))
	}

	@Test def void testBeginningAndEnd() {
		val data = newArrayList()
		data += "aaaaaaaaaa" -> "aaaaaaaaaa"
		data += "aaaaaaaaaa" -> "aaaaa-aaaa"
		data += "aaaaaaaaaa" -> "aaaa--aaaa"
		data += "aaaaaaaaaa" -> "aaaa---aaa"
		data += "aaaaaaaaaa" -> "aaa----aaa"
		data += "aaaaaaaaaa" -> "aaa-----aa"
		data += "aaaaaaaaaa" -> "aa------aa"
		data += "aaaaaaaaaa" -> "aa-------a"
		data += "aaaaaaaaaa" -> "a--------a"
		data += "aaaaaaaaaa" -> "a---------"
		data += "aaaaaaaaaa" -> "----------"

		val expected = '''
			aaaaaaaaaa <> aaaaaaaaaa --> 0.00
			aaaaaaaaaa <> aaaaa-aaaa --> 0.25
			aaaaaaaaaa <> aaaa--aaaa --> 0.50
			aaaaaaaaaa <> aaaa---aaa --> 0.75
			aaaaaaaaaa <> aaa----aaa --> 1.00
			aaaaaaaaaa <> aaa-----aa --> 1.00
			aaaaaaaaaa <> aa------aa --> 1.00
			aaaaaaaaaa <> aa-------a --> 1.00
			aaaaaaaaaa <> a--------a --> 1.00
			aaaaaaaaaa <> a--------- --> 1.00
			aaaaaaaaaa <> ---------- --> 1.00
		'''

		assertEquals(expected.trim, similarityStr(data))
	}

	def String similarityStr(Pair<String, String> ... pairs) {
		pairs.map['''«key» <> «value» --> «format(similarity(key, value))»'''].join("\n")
	}

	def float similarity(String s1, String s2) {
		new StringEndsSimilarityFunction().similarity(s1, s2)
	}
	
	/**
	 * Defines a reproducible float output format for the test, using US locale.
	 */
	def String format(float value)
	{
		String.format(Locale.US,"%.2f", value)
	}
}
