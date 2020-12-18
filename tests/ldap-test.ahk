;@Ahk2Exe-ConsoleApp
; ahk: x86
#NoEnv
SetBatchLines -1
#Warn All, StdOut

#Include <testcase-libs>
#Include <system>
#Include <structure>

#Include %A_ScriptDir%\..\ldap.ahk
#Include <modules\structure\LDAPAPIInfo>
#Include <modules\structure\LDAPMod>

class LdapTest extends TestCase {

	requires() {
		return [TestCase, Ldap]
	}

	static SERVER := "localhost"
	static PORT := 10389
	static ADMINUSER := "cn=admin,dc=example,dc=com"
	static PASSWORD := "secret"
	static BASE_DN := "dc=example,dc=com"
	static VI_SERVER := "lxs150w05.viessmann.com"
	static VI_PORT := 389

	static ld := 0
	static coverLdapService := false

	@BeforeClass_SetUp() {
		testLdap := new Ldap(LdapTest.SERVER, LdapTest.PORT)
		if (testLdap.connect() != 0) {	
			TestCase.writeLine("Starting Ldap...")
			LdapTest.startDockerLdap()
			LdapTest.coverLdapService := true
		} else {
			TestCase.writeLine("Ldap is already reachable")
		}
		testLdap.unbind()
		Ldap.hWldap32 := 0
	}

	@AfterClass_TeadDown() {
		if (LdapTest.coverLdapService) {
			TestCase.writeLine("`nStopping Ldap...")
			LdapTest.stopDockerLdap()
		}
	}
	
	@AfterClass_unbind() {
		if (LdapTest.ld != 0) {
			LdapTest.ld.unbind()
		}
	}

	@Test_AW() {
		if (A_IsUnicode) {
			this.assertEquals(Ldap.AW, "W")
		} else {
			this.assertEquals(Ldap.AW, "A")
		}
	}

	@Test_Constants() {
		this.assertEquals(Ldap.SCOPE_BASE, 0)
		this.assertEquals(Ldap.SCOPE_ONELEVEL, 1)
		this.assertEquals(Ldap.SCOPE_SUBTREE, 2)
		this.assertEquals(Ldap.MOD_ADD, 0)
		this.assertEquals(Ldap.MOD_DELETE, 1)
		this.assertEquals(Ldap.MOD_REPLACE, 2)

		this.assertEquals(Ldap.OPT_API_INFO, 0x00)
		this.assertEquals(Ldap.OPT_API_FEATURE_INFO, 0x15)
		this.assertEquals(Ldap.OPT_AREC_EXCLUSIVE, 0x98)
		this.assertEquals(Ldap.OPT_AUTO_RECONNECT, 0x91)
		this.assertEquals(Ldap.OPT_CACHE_ENABLE, 0x0F)
		this.assertEquals(Ldap.OPT_CACHE_FN_PTRS, 0x0D)
		this.assertEquals(Ldap.OPT_CACHE_STRATEGY, 0x0E)
		this.assertEquals(Ldap.OPT_CLIENT_CERTIFICATE, 0x80)
		this.assertEquals(Ldap.OPT_DEREF, 0x02)
		this.assertEquals(Ldap.OPT_DESC, 0x01)
		this.assertEquals(Ldap.OPT_DNSDOMAIN_NAME, 0x3B)
		this.assertEquals(Ldap.OPT_ENCRYPT, 0x96)
		this.assertEquals(Ldap.OPT_ERROR_NUMBER, 0x31)
		this.assertEquals(Ldap.OPT_ERROR_STRING, 0x32)
		this.assertEquals(Ldap.OPT_FAST_CONCURRENT_BIND, 0x41)
		this.assertEquals(Ldap.OPT_GETDSNAME_FLAGS, 0x3D)
		this.assertEquals(Ldap.OPT_HOST_NAME, 0x30)
		this.assertEquals(Ldap.OPT_HOST_REACHABLE, 0x3E)
		this.assertEquals(Ldap.OPT_IO_FN_PTRS, 0x0B)
		this.assertEquals(Ldap.OPT_PING_KEEP_ALIVE, 0x36)
		this.assertEquals(Ldap.OPT_PING_LIMIT, 0x38)
		this.assertEquals(Ldap.OPT_PING_WAIT_TIME, 0x37)
		this.assertEquals(Ldap.OPT_PROMPT_CREDENTIALS, 0x3F)
		this.assertEquals(Ldap.OPT_PROTOCOL_VERSION, 0x11)
		this.assertEquals(Ldap.OPT_VERSION, 0x11)
		this.assertEquals(Ldap.OPT_REBIND_ARG, 0x07)
		this.assertEquals(Ldap.OPT_REBIND_FN, 0x06)
		this.assertEquals(Ldap.OPT_REF_DEREF_CONN_PER_MSG, 0x94)
		this.assertEquals(Ldap.OPT_REFERAL_CALLBACK, 0x70)
		this.assertEquals(Ldap.OPT_REFERAL_HOP_LIMIT, 0x10)
		this.assertEquals(Ldap.OPT_REFERALS, 0x08)
		this.assertEquals(Ldap.OPT_RESTART, 0x09)
		this.assertEquals(Ldap.OPT_ROOTDSE_CACHE, 0x9A)
		this.assertEquals(Ldap.OPT_SASL_METHOD, 0x97)
		this.assertEquals(Ldap.OPT_SECURITY_CONTEXT, 0x99)
		this.assertEquals(Ldap.OPT_SEND_TIMEOUT, 0x42)
		this.assertEquals(Ldap.OPT_SCH_FLAGS, 0x43)
		this.assertEquals(Ldap.OPT_SOCKET_BIND_ADDRESSES, 0x44)
		this.assertEquals(Ldap.OPT_SERVER_CERTIFICATE, 0x81)
		this.assertEquals(Ldap.OPT_SERVER_ERROR, 0x33)
		this.assertEquals(Ldap.OPT_SERVER_EXT_ERROR, 0x34)
		this.assertEquals(Ldap.OPT_SIGN, 0x95)
		this.assertEquals(Ldap.OPT_SIZELIMIT, 0x03)
		this.assertEquals(Ldap.OPT_SSL, 0x0A)
		this.assertEquals(Ldap.OPT_SSL_INFO, 0x93)
		this.assertEquals(Ldap.OPT_SSPI_FLAGS, 0x92)
		this.assertEquals(Ldap.OPT_TCP_KEEPALIVE, 0x40)
		this.assertEquals(Ldap.OPT_THREAD_FN_PTRS, 0x05)
		this.assertEquals(Ldap.OPT_TIMELIMIT, 0x04)

		this.assertEquals(Ldap.OPT_ON, true)
		this.assertEquals(Ldap.OPT_OFF, false)

		this.assertEquals(Ldap.DEREF_NEVER, 0x00)
		this.assertEquals(Ldap.DEREF_SEARCHING, 0x01)
		this.assertEquals(Ldap.DEREF_FINDING, 0x02)
		this.assertEquals(Ldap.DEREF_ALWAYS, 0x03)

		this.assertEquals(Ldap.VERSION1, 1)
		this.assertEquals(Ldap.VERSION2, 2)
		this.assertEquals(Ldap.VERSION3, 3)

		this.assertEquals(Ldap.CHASE_SUBORDINATE_REFERALS, 0x20)
		this.assertEquals(Ldap.CHASE_EXTERNAL_REFERALS, 0x40)

		this.assertEquals(Ldap.AUTH_NEGOTIATE, 0x400)

		this.assertEquals(Ldap.NO_LIMIT, 0)

		this.assertEquals(Ldap.LDAP_API_INFO_VERSION, 1)
	}

	@Test_ServerUnAvailable() {
		this.assertEquals(Ldap.hWldap32, 0)
		l := new Ldap("localhost", 0)
		if (!Ldap.hWldap32) {
			this.fail("*** FATAL: Wldap32.dll could not be loaded",, true)
		}
		this.assertEquals(l.connect(), 81)
	}

	@Test_ServerAvailable() {
		LdapTest.ld := new Ldap(LdapTest.SERVER, LdapTest.PORT)
		try {
			this.assertEquals(LdapTest.ld.connect(), 0)
		} catch _ex {
			this.fail("*** FATAL ", _ex.message, true)
		}
	}

	@Test_reconnectWithV3() {
		this.assertEquals(LdapTest.ld.setOption(Ldap.OPT_VERSION
				, Ldap.VERSION3), 0)
		this.assertEquals(LdapTest.ld.connect(), 0)
		this.assertEquals(LdapTest.ld.simpleBind(LdapTest.ADMINUSER
				, LdapTest.PASSWORD), 0)
	}

	@Depend_@Test_SetOption() {
		return "@Test_ServerAvailable"
	}
	@Test_SetOption() {
		this.assertEquals(LdapTest.ld.setOption(Ldap.OPT_VERSION, Ldap.VERSION3)
				, 0)
		VarSetCapacity(sl, 4, 0)
		NumPut(4, sl, 0, "UInt")
		this.assertEquals(LdapTest.ld.setOption(Ldap.OPT_SIZELIMIT, &sl), 0)
		VarSetCapacity(tl, 4, 0)
		NumPut(10, tl, 0, "UInt")
		this.assertEquals(LdapTest.ld.setOption(Ldap.OPT_TIMELIMIT, &tl), 0)
	}

	@Depend_@Test_GetOption() {
		return "@Test_ServerAvailable,@Test_reconnectWithV3,@Test_SetOption"
	}
	@Test_GetOption() {
		ai := new LDAPAPIInfo()
		ai.ldapai_info_version := Ldap.LDAP_API_INFO_VERSION
		ai.implode(apiInfo)
		LdapTest.ld.getOption(Ldap.OPT_API_INFO, apiInfo)
		ai.explode(apiInfo)
		this.assertEquals(ai.ldapai_info_version, 1)
		this.assertEquals(ai.ldapai_api_version, 2004)
		this.assertEquals(ai.ldapai_protocol_version, 3)
		this.assertTrue(Arrays.equal(ai.ldapai_extensions
				, ["VIRTUAL_LIST_VIEW"]))
		this.assertEquals(ai.ldapai_vendor_name, "Microsoft Corporation.")
		this.assertEquals(ai.ldapai_vendor_version, 510)
		VarSetCapacity(a_e, 4, 0)
		this.assertEquals(LdapTest.ld.getOption(Ldap.OPT_AREC_EXCLUSIVE, a_e)
				, 0)
		this.assertEquals(NumGet(&a_e, 0, "UInt"), Ldap.OPT_OFF)
		VarSetCapacity(hostname, A_PtrSize, 0)
		this.assertEquals(LdapTest.ld.getOption(Ldap.OPT_HOST_NAME, hostname)
				, 0)
		this.assertTrue(RegExMatch(StrGet(NumGet(&hostname, 0, "Ptr"))
				, A_ComputerName "(\..+)?"))
		VarSetCapacity(r_h_l, 4, 0)
		this.assertEquals(LdapTest.ld.getOption(Ldap.OPT_REFERAL_HOP_LIMIT
				, r_h_l), 0)
		this.assertEquals(NumGet(&r_h_l, 0, "UInt"), 32)
		VarSetCapacity(refs, 4, 0)
		this.assertEquals(LdapTest.ld.getOption(Ldap.OPT_REFERALS, refs), 0)
		this.assertEquals(NumGet(&refs, 0, "UInt"), Ldap.OPT_ON)
		VarSetCapacity(sl, 4, 0)
		this.assertEquals(LdapTest.ld.getOption(Ldap.OPT_SIZELIMIT, sl), 0)
		this.assertEquals(NumGet(sl, 0, "UInt"), 4)
		VarSetCapacity(ssl, 4, 0)
		this.assertEquals(LdapTest.ld.getOption(Ldap.OPT_SSL, ssl), 0)
		this.assertEquals(NumGet(ssl, 0, "UInt"), Ldap.OPT_OFF)
		VarSetCapacity(tl, 4, 0)
		this.assertEquals(LdapTest.ld.getOption(Ldap.OPT_TIMELIMIT, tl), 0)
		this.assertEquals(NumGet(tl, 0, "UInt"), 10)
		VarSetCapacity(ar, 4, 0)
		this.assertEquals(LdapTest.ld.getOption(Ldap.OPT_AUTO_RECONNECT, ar), 0)
		this.assertEquals(NumGet(ar, 0, "UInt"), Ldap.OPT_ON)
		VarSetCapacity(pc, 4, 0)
		this.assertEquals(LdapTest.ld.getOption(Ldap.OPT_AUTO_RECONNECT, pc), 0)
		this.assertEquals(NumGet(pc, 0, "UInt"), Ldap.OPT_ON)
	}

	@Depend_@Test_bind() {
		return "@Test_ServerAvailable,@Test_reconnectWithV3"
	}
	@Test_bind() {
		this.assertEquals(LdapTest.ld.simpleBind(LdapTest.ADMINUSER
				, LdapTest.PASSWORD), 0)
	}

	@Depend_@Test_getDN() {
		return "@Test_Bind"
	}
	@Test_getDN() {
		this.assertEquals(LdapTest.ld.search(sr, LdapTest.BASE_DN, "(cn=admin)"
				,, ["cn"]), 0)
		this.assertEquals(ldapTest.ld.countEntries(sr), 1)
		1stEntry := LdapTest.ld.firstEntry(sr)
		1stAttr := LdapTest.ld.firstAttribute(1stEntry)
		System.strCpy(1stAttr, stAttr)
		this.assertEquals(stAttr, "cn")
		valuesList := LdapTest.ld.getValues(1stEntry, 1stAttr)
		this.assertEquals(System.ptrListToStrArray(valuesList)[1], "admin")
	}

	@Depend_@Test_countEntries() {
		return "@Test_bind"
	}
	@Test_countEntries() {
		this.assertEquals(LdapTest.ld.search(sr, "", "(ou=*)"
				, Ldap.SCOPE_ONELEVEL), 0)
		this.assertEquals(LdapTest.ld.countEntries(sr), 1)
	}

	@Depend_@Test_add() {
		return "@Test_bind"
	}
	@Test_add() {
		cn := new LDAPMod({mod_op: Ldap.MOD_ADD, mod_type: "cn"
				, mod_vals: ["Peter Pan"]})
				.implode(_cn)
		oc := new LDAPMod({mod_op: Ldap.MOD_ADD, mod_type: "objectClass"
				, mod_vals: ["top", "person", "inetOrgPerson"]})
				.implode(_oc)
		givenName := new LDAPMod({mod_op: Ldap.MOD_ADD, mod_type: "givenName"
				, mod_vals: ["Peter"]})
				.implode(_givenName)
		sn := new LDAPMod({mod_op: Ldap.MOD_ADD, mod_type: "sn"
				, mod_vals: ["Pan"]})
				.implode(_sn)
		title := new LDAPMod({mod_op: Ldap.MOD_ADD, mod_type: "title"
				, mod_vals: ["Developer"]})
				.implode(_title)
		System.ptrList(newEntry, &_cn, &_oc, &_givenName, &_sn, &_title, 0)
		rc := LdapTest.ld.add("cn=Peter Pan,dc=example,dc=com", newEntry)
		if (rc) {
			this.fail("Entry to create already existing!`nTo delete"
					, Format("ldapdelete -h localhost:{:i} -D {:s} "
					. "-w {:s} ""cn=Peter Pan,dc=example,dc=com"""
					, LdapTest.PORT, LdapTest.ADMINUSER, LdapTest.PASSWORD)
					, true)
		}
	}

	@Depend_@Test_modify() {
		return "@Test_add"
	}
	@Test_modify() {
		sn := new LDAPMod({mod_op: Ldap.MOD_REPLACE, mod_type: "sn"
				, mod_vals: ["Black"]})
				.implode(_sn)
		title := new LDAPMod({mod_op: Ldap.MOD_REPLACE, mod_type: "title"
				, mod_vals: ["Administrator"
				, "Lightning And Strike Detonator"]})
				.implode(_title)
		System.ptrList(modEntry, &_title, &_sn, 0)
		rc := LdapTest.ld.modify("cn=Peter Pan,dc=example,dc=com", modEntry)
		this.assertEquals(rc, 0)
	}

	@Test_formatFilter() {
		expected_output =
(
	(objectclass=top)
)
		this.assertEquals(Ldap.formatFilter("(objectclass=top)", false)
				, expected_output)
		; ahklint-ignore-begin: W002,W003
		Example0 := "(&(objectCategory=person)(objectClass=user)(!(userAccountControl:1.2.840.113556.1.4.803:=2))(|(accountExpires=0)(accountExpires=9223372036854775807)))"
		Example0_output := "(&`n"
				. "  (objectCategory=person)`n"
				. "  (objectClass=user)`n"
				. "  (!`n"
				. "    (userAccountControl:1.2.840.113556.1.4.803:=2)`n"
				. "  )`n"
				. "  (|`n"
				. "    (accountExpires=0)`n"
				. "    (accountExpires=9223372036854775807)`n"
				. "  )`n"
				. ")"
		Example1 := "(&(objectCategory=person)(objectClass=user)(!(userAccountControl:1.2.840.113556.1.4.803:=2))(|(accountExpires=0)(accountExpires=9223372036854775807))(userAccountControl:1.2.840.113556.1.4.803:=65536))"
		Example1_output := "(&`n"
				. "  (objectCategory=person)`n"
				. "  (objectClass=user)`n"
				. "  (!`n"
				. "    (userAccountControl:1.2.840.113556.1.4.803:=2)`n"
				. "  )`n"
				. "  (|`n"
				. "    (accountExpires=0)`n"
				. "    (accountExpires=9223372036854775807)`n"
				. "  )`n"
				. "  (userAccountControl:1.2.840.113556.1.4.803:=65536)`n"
				. ")"
		Example2 := "(&(&(!(cn:dn:=jbond))(|(ou:dn:=ResearchAndDevelopment)(ou:dn:=HumanResources)))(objectclass=Person))"
		Example2_output := "(&`n"
				. "  (&`n"
				. "    (!`n"
				. "      (cn:dn:=jbond)`n"
				. "    )`n"
				. "    (|`n"
				. "      (ou:dn:=ResearchAndDevelopment)`n"
				. "      (ou:dn:=HumanResources)`n"
				. "    )`n"
				. "  )`n"
				. "  (objectclass=Person)`n"
				. ")"
		Example3 := "(&(&(!(cn:dn:=jbond))(|(ou:dn:=ResearchAndDevelopment)(ou:dn:=HumanResources)))(objectclass=Person))"
		Example3_output := "([0;32m&[0m`n"
				. "  ([0;32m&[0m`n"
				. "    ([0;32m![0m`n"
				. "      (cn:dn:[0;35m[0;31m=[0m[0;34mjbond[0m)`n"
				. "    )`n"
				. "    ([0;32m|[0m`n"
				. "      (ou:dn:[0;35m[0;31m=[0m[0;34mResearchAndDevelopment[0m)`n"
				. "      (ou:dn:[0;35m[0;31m=[0m[0;34mHumanResources[0m)`n"
				. "    )`n"
				. "  )`n"
				. "  ([0;35mobjectclass[0;31m=[0m[0;34mPerson[0m)`n"
				. ")"
		; ahklint-ignore-end
		this.assertEquals(Ldap.formatFilter(Example0, false), Example0_output)
		this.assertEquals(Ldap.formatFilter(Example1, false), Example1_output)
		this.assertEquals(Ldap.formatFilter(Example2, false), Example2_output)
		this.assertEquals(Ldap.formatFilter(Example3, true), Example3_output)
		this.assertException(Ldap, "FormatFilter",,, "cn=*))")
	}

	@Depend_@Test_searchByDN() {
		return "@Test_modify"
	}
	@Test_searchByDN() {
		values := []
		this.assertException(LdapTest.ld, "Search",,, sr := ""
				, "cn=Peter Pan,dc=example,dc=com", "(objectclass=*)"
				,, "string_nicht_erlaubt")
		this.assertEquals(LdapTest.ld.search(sr
				, "cn=Peter Pan,dc=example,dc=com"
				, "(objectclass=*)",, ["title", "sn"]), 0)
		1stEntry := LdapTest.ld.firstEntry(sr)
		1stAttr := LdapTest.ld.firstAttribute(1stEntry)
		values.push(System.ptrListToStrArray(LdapTest.ld
				.getValues(1stEntry, 1stAttr), false))
		2ndAttr := LdapTest.ld.nextAttribute(1stEntry)
		values.push(System.ptrListToStrArray(LdapTest.ld
				.getValues(1stEntry, 2ndAttr), false))
		this.assertTrue(Arrays.equal(Arrays.sort(Arrays.flat(values))
				, ["Administrator", "Black", "Lightning And Strike Detonator"]))
	}

	@Depend_@Test_searchAttributes() {
		return "@Test_modify"
	}
	@Test_searchAttributes() {
		values := []
		this.assertEquals(LdapTest.ld.search(sr, "dc=example,dc=com"
				, "(cn=Peter Pan)",, ["title", "sn"]), 0)
		1stEntry := LdapTest.ld.firstEntry(sr)
		1stAttr := LdapTest.ld.firstAttribute(1stEntry)
		values.push(System.ptrListToStrArray(LdapTest.ld
				.getValues(1stEntry, 1stAttr), false))
		2ndAttr := LdapTest.ld.nextAttribute(1stEntry)
		values.push(System.ptrListToStrArray(LdapTest.ld
				.getValues(1stEntry, 2ndAttr), false))
		this.assertTrue(Arrays.equal(Arrays.sort(Arrays.flat(values))
				, ["Administrator", "Black", "Lightning And Strike Detonator"]))
	}

	@Depend_@Test_searchMultiple() {
		return "@Test_serverAvailable"
	}
	@Test_searchMultiple() {
		values := []
		this.assertEquals(LdapTest.ld.search(sr, "dc=example,dc=com"
				, "(sn=van Pelt)", 2, ["givenname"]), 0)
		1stEntry := LdapTest.ld.firstEntry(sr)
		1stAttr := LdapTest.ld.firstAttribute(1stEntry)
		values.push(System.ptrListToStrArray(LdapTest.ld
				.getValues(1stEntry, 1stAttr), false))
		nxtEntry := LdapTest.ld.nextEntry(1stEntry)
		1stAttr := LdapTest.ld.firstAttribute(nxtEntry)
		values.push(System.ptrListToStrArray(LdapTest.ld
				.getValues(nxtEntry, 1stAttr), false))
		this.assertEquals(Arrays.equal(Arrays.flat(Arrays.sort(values)
				, ["Linus", "Lucy"])))
		this.assertEquals(LdapTest.ld.nextEntry(nxtEntry), 0)
		this.assertEquals(LdapTest.ld.getLastError(), 0)
	}

	@Depend_@Test_delete() {
		return "@Test_add"
	}
	@Test_delete() {
		rc := LdapTest.ld.delete("cn=Peter Pan,dc=example,dc=com")
		this.assertEquals(rc, 0)
	}

	@Depend_@Test_errors() {
		return "@Test_serverAvailable"
	}
	@Test_errors() {
		this.assertEquals(LdapTest.ld.err2String(), "Erfolg")
		this.assertEquals(LdapTest.ld.err2String(32), "Objekt nicht vorhanden")
	}

	@Depend_@Test_unbind() {
		return "@Test_bind"
	}
	@Test_unbind() {
		this.assertEquals(LdapTest.ld.unbind(), 0)
	}

	@Test_VILdap() {
		LdapTest.ld_vi := new Ldap(LdapTest.VI_SERVER, LdapTest.VI_PORT)
		try {
			this.assertEquals(LdapTest.ld_vi.connect(), 0)
		} catch _ex {
			this.fail("*** FATAL ", _ex.message, true)
		}
		this.assertEquals(LdapTest.ld_vi.search(sr
				, "dc=viessmann,dc=net", "cn=tam_blacklist"), 0)
		this.assertEquals(LdapTest.ld_vi.countEntries(sr), 1)
		1stEntry := LdapTest.ld_vi.firstEntry(sr)
		this.assertEqualsIgnoreCase(LdapTest.ld_vi.getDn(1stEntry)
				, "cn=tam_blacklist,ou=groups,dc=viessmann,dc=net")
		this.assertEquals(LdapTest.ld_vi.unbind(), 0)
	}

	startDockerLdap() {
		RunWait %COMSPEC% /c ""docker-compose" "-f" "ldap/openldap.yaml" "up" "-d"", %A_ScriptDir% ; ahklint-ignore: W002
		sleep 1000
	}

	stopDockerLdap() {
		RunWait %COMSPEC% /c ""docker-compose" "-f" "ldap/openldap.yaml" "down"", %A_ScriptDir% ; ahklint-ignore: W002
	}

	startApacheDsLdap() {
		for ldap_svc in ComObjGet("winmgmts:")
				.execQuery("Select * from Win32_Service where Name='apacheds-default'") { ; ahklint-ignore: W002
			if (ldap_svc.state != "Running") {
				LdapTest.coverLdapService := true
				if ((ldap_rc := ldap_svc.startService()) != 0) {
					this.fail("*** FATAL: apacheds-default service "
							. "could not be startet: " ldap_rc,, true)
				}
				LdapTest.waitForApacheDsState("Running")
			} else {
				TestCase.writeLine("apacheds-default service is already running") ; ahklint-ignore: W002
			}
			break
		}
	}

	stopApacheDsLdap() {
		if (LdapTest.coverLdapService) {
			for ldap_svc in ComObjGet("winmgmts:")
					.execQuery("Select * from Win32_Service where Name='apacheds-default'") { ; ahklint-ignore: W002
				if (ldap_svc.state = "Running") {
					TestCase.writeLine("Stopping apacheds-default service...") ; ahklint-ignore: W002
					if ((ldap_rc := ldap_svc.stopService()) != 0) {
						this.fail("*** FATAL: apacheds-default service "
								. "could not be stopped: " ldap_rc,, true)
					}
					LdapTest.waitForApacheDsState("Stopped")
				} else {
					TestCase.writeLine("apacheds-default service has already been stopped") ; ahklint-ignore: W002
				}
				break
			}
		}
	}

	waitForApacheDsState(expectedState) {
		max_tries := 600
		while (max_tries > 0 && ldap_svc.state != expectedState) {
			sleep 100
			for ldap_svc in ComObjGet("winmgmts:")
					.execQuery("Select * from Win32_Service where Name='apacheds-default'") { ; ahklint-ignore: W002
				break
			}
			max_tries--
		}
		if (max_tries = 0) {
			this.fail(Format("*** FATAL: apacheds-default service "
					. "did not reach state '{:s}' in an adequate time"
					, expectedState),, true)
		} else {
			TestCase.writeLine(Format("apacheds-default service is in state "
					.  " {:s}", expectedState)) ; ahklint-ignore: W002
		}
	}
}

exitapp LdapTest.runTests()
