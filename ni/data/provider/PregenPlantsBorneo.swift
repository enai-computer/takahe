//
//  PregenPlantsBorneo.swift
//  Enai
//
//  Created by Patrick Lukas on 10/12/24.
//

class PregenPlantsBorneo {
	
	let contentTable_sql = """
INSERT INTO "content" ("id", "title", "type", "updated_at", "local_storage_location", "ref_counter", "source_url") VALUES ('3FFE5183-18F3-4E15-90D2-4582A8D951EA', 'Ironwood (Eusideroxylon zwageri) - Google Search', 'web', '1732026461.65979', NULL, '1', NULL);
INSERT INTO "content" ("id", "title", "type", "updated_at", "local_storage_location", "ref_counter", "source_url") VALUES ('B47892B0-5AC1-4B81-9BDD-5FBD4CF7DC81', 'Eusideroxylon - Wikipedia', 'web', '1732026491.65746', NULL, '1', NULL);
INSERT INTO "content" ("id", "title", "type", "updated_at", "local_storage_location", "ref_counter", "source_url") VALUES ('487317A2-B4F9-4609-81A8-729AB0AAFCE3', 'Photos of Bornean ironwood (Eusideroxylon zwageri) · iNaturalist', 'web', '1732026551.66062', NULL, '1', NULL);
INSERT INTO "content" ("id", "title", "type", "updated_at", "local_storage_location", "ref_counter", "source_url") VALUES ('C32FB10C-B080-4DC2-A529-E91ADE290581', 'Teak - Wikipedia', 'web', '1732027151.65592', NULL, '1', NULL);
INSERT INTO "content" ("id", "title", "type", "updated_at", "local_storage_location", "ref_counter", "source_url") VALUES ('E4AF1975-C7EC-4FD6-B3F2-CD0F6D4A2278', 'Teak (Tectona grandis) is a tropical hardwood tree species in the family Lamiaceae. It is a large, deciduous tree that occurs in mixed hardwood forests. Tectona grandis has small, fragrant white flowers arranged in dense clusters (panicles) at the end of the branches. These flowers contain both types of reproductive organs (perfect flowers). The large, papery leaves of teak trees are often hairy on the lower surface. Teak wood has a leather-like smell when it is freshly milled and is particularly valued for its durability and water resistance. The wood is used for boat building, exterior construction, veneer, furniture, carving, turnings, and various small projects.', 'note', '1733780292.86561', NULL, '1', NULL);
INSERT INTO "content" ("id", "title", "type", "updated_at", "local_storage_location", "ref_counter", "source_url") VALUES ('7E06398B-FEDE-44F1-8D6A-6FF28384834C', 'Teak | The Wood Database (Hardwood)', 'web', '1732114193.59481', NULL, '1', NULL);
INSERT INTO "content" ("id", "title", "type", "updated_at", "local_storage_location", "ref_counter", "source_url") VALUES ('34E901A1-AD59-4167-BCDD-2C35139C5D4F', 'What is teak wood, and why is it so great anyway?', 'web', '1732114193.59641', NULL, '1', NULL);
INSERT INTO "content" ("id", "title", "type", "updated_at", "local_storage_location", "ref_counter", "source_url") VALUES ('A94C79A7-3D4B-4726-8C5A-6ADD144F5C38', 'Teak | Uses, Benefits & Characteristics | Britannica', 'web', '1732114193.59806', NULL, '1', NULL);
INSERT INTO "content" ("id", "title", "type", "updated_at", "local_storage_location", "ref_counter", "source_url") VALUES ('D8AEBF43-BAC6-450C-A468-00B2B9FBC80D', 'The Teak House | The Common', 'web', '1732114193.59977', NULL, '1', NULL);
INSERT INTO "content" ("id", "title", "type", "updated_at", "local_storage_location", "ref_counter", "source_url") VALUES ('677F7F5B-FA94-4F0A-ACA3-BD31423391E8', 'The grave human cost of teak wood - and alternatives - Yachting World', 'web', '1732114193.60095', NULL, '1', NULL);
INSERT INTO "content" ("id", "title", "type", "updated_at", "local_storage_location", "ref_counter", "source_url") VALUES ('67F4BB75-C1AC-4E4E-8D9B-5D37DC8CD518', 'Eusideroxylon is a genus of evergreen trees of the family Lauraceae. The genus is monotypic, and includes one accepted species, Eusideroxylon zwageri. It is known colloquially in English as Bornean ironwood, billian, or ulin.', 'note', '1733780053.51628', NULL, '1', NULL);
INSERT INTO "content" ("id", "title", "type", "updated_at", "local_storage_location", "ref_counter", "source_url") VALUES ('CACDA107-0597-4D8D-8F47-8E97CCBE3F8D', 'Biodiversity of Borneo - Wikipedia', 'web', '1733830268.8698', NULL, '1', NULL);
"""
	
	let doc_content_sql = """
INSERT INTO "doc_id_content_id" ("document_id", "content_id") VALUES ('4D0CEF6E-9ECC-4B83-9A9B-F1CC249CAF92', '3FFE5183-18F3-4E15-90D2-4582A8D951EA');
INSERT INTO "doc_id_content_id" ("document_id", "content_id") VALUES ('4D0CEF6E-9ECC-4B83-9A9B-F1CC249CAF92', 'B47892B0-5AC1-4B81-9BDD-5FBD4CF7DC81');
INSERT INTO "doc_id_content_id" ("document_id", "content_id") VALUES ('4D0CEF6E-9ECC-4B83-9A9B-F1CC249CAF92', '487317A2-B4F9-4609-81A8-729AB0AAFCE3');
INSERT INTO "doc_id_content_id" ("document_id", "content_id") VALUES ('4D0CEF6E-9ECC-4B83-9A9B-F1CC249CAF92', 'C32FB10C-B080-4DC2-A529-E91ADE290581');
INSERT INTO "doc_id_content_id" ("document_id", "content_id") VALUES ('4D0CEF6E-9ECC-4B83-9A9B-F1CC249CAF92', 'E4AF1975-C7EC-4FD6-B3F2-CD0F6D4A2278');
INSERT INTO "doc_id_content_id" ("document_id", "content_id") VALUES ('4D0CEF6E-9ECC-4B83-9A9B-F1CC249CAF92', '7E06398B-FEDE-44F1-8D6A-6FF28384834C');
INSERT INTO "doc_id_content_id" ("document_id", "content_id") VALUES ('4D0CEF6E-9ECC-4B83-9A9B-F1CC249CAF92', '34E901A1-AD59-4167-BCDD-2C35139C5D4F');
INSERT INTO "doc_id_content_id" ("document_id", "content_id") VALUES ('4D0CEF6E-9ECC-4B83-9A9B-F1CC249CAF92', 'A94C79A7-3D4B-4726-8C5A-6ADD144F5C38');
INSERT INTO "doc_id_content_id" ("document_id", "content_id") VALUES ('4D0CEF6E-9ECC-4B83-9A9B-F1CC249CAF92', 'D8AEBF43-BAC6-450C-A468-00B2B9FBC80D');
INSERT INTO "doc_id_content_id" ("document_id", "content_id") VALUES ('4D0CEF6E-9ECC-4B83-9A9B-F1CC249CAF92', '677F7F5B-FA94-4F0A-ACA3-BD31423391E8');
INSERT INTO "doc_id_content_id" ("document_id", "content_id") VALUES ('4D0CEF6E-9ECC-4B83-9A9B-F1CC249CAF92', '67F4BB75-C1AC-4E4E-8D9B-5D37DC8CD518');
INSERT INTO "doc_id_content_id" ("document_id", "content_id") VALUES ('4D0CEF6E-9ECC-4B83-9A9B-F1CC249CAF92', 'CACDA107-0597-4D8D-8F47-8E97CCBE3F8D');
"""
	
	let cached_web_sql = """
INSERT INTO "cached_Web" ("content_id", "url", "updated_at", "cache", "html_website") VALUES ('3FFE5183-18F3-4E15-90D2-4582A8D951EA', 'https://www.google.com/search?sca_esv=0734fda996d53699&sxsrf=ADLYWIKucdDujc80W0U1Bu3pT7uVV32N1w:1732026459663&q=Ironwood+(Eusideroxylon+zwageri)&udm=2&fbs=AEQNm0Aa4sjWe7Rqy32pFwRj0UkWd8nbOJfsBGGB5IQQO6L3J_86uWOeqwdnV0yaSF-x2jqw-AzvpDFRWNmLZKilfTrfO0pl9dtT9e2t2elzSdzPviJlaPtdkm_zev73LcACj_Zt3WoLu1loKbhUBQ0BvD6_OC9OERnpW26hAPVqw_fTJrjRkQgEJf5SXlzvVj2JhcxyIvER&sa=X&ved=2ahUKEwiOlvquzeiJAxUwBNsEHbXLJ2wQtKgLegQIDxAB&biw=1391&bih=840&dpr=2#vhid=WMhxKhl2tNWFQM&vssid=mosaic', '1732026521.65816', NULL, NULL);
INSERT INTO "cached_Web" ("content_id", "url", "updated_at", "cache", "html_website") VALUES ('B47892B0-5AC1-4B81-9BDD-5FBD4CF7DC81', 'https://en.wikipedia.org/wiki/Eusideroxylon', '1732026491.65804', NULL, NULL);
INSERT INTO "cached_Web" ("content_id", "url", "updated_at", "cache", "html_website") VALUES ('487317A2-B4F9-4609-81A8-729AB0AAFCE3', 'https://www.inaturalist.org/taxa/192894-Eusideroxylon-zwageri/browse_photos', '1732026551.6619', NULL, NULL);
INSERT INTO "cached_Web" ("content_id", "url", "updated_at", "cache", "html_website") VALUES ('C32FB10C-B080-4DC2-A529-E91ADE290581', 'https://en.wikipedia.org/wiki/Teak#', '1732027151.65705', NULL, NULL);
INSERT INTO "cached_Web" ("content_id", "url", "updated_at", "cache", "html_website") VALUES ('7E06398B-FEDE-44F1-8D6A-6FF28384834C', 'https://www.wood-database.com/teak/', '1732114193.5955', NULL, NULL);
INSERT INTO "cached_Web" ("content_id", "url", "updated_at", "cache", "html_website") VALUES ('34E901A1-AD59-4167-BCDD-2C35139C5D4F', 'https://www.capulet.co.nz/blog/3-what-is-teak-wood-and-why-is-it-so-great-anyway-', '1732114193.597', NULL, NULL);
INSERT INTO "cached_Web" ("content_id", "url", "updated_at", "cache", "html_website") VALUES ('A94C79A7-3D4B-4726-8C5A-6ADD144F5C38', 'https://www.britannica.com/plant/teak', '1732114193.59884', NULL, NULL);
INSERT INTO "cached_Web" ("content_id", "url", "updated_at", "cache", "html_website") VALUES ('D8AEBF43-BAC6-450C-A468-00B2B9FBC80D', 'https://www.thecommononline.org/the-teak-house/', '1732114193.60011', NULL, NULL);
INSERT INTO "cached_Web" ("content_id", "url", "updated_at", "cache", "html_website") VALUES ('677F7F5B-FA94-4F0A-ACA3-BD31423391E8', 'https://www.yachtingworld.com/features/the-grave-human-cost-of-teak-wood-135147', '1732114193.6013', NULL, NULL);
INSERT INTO "cached_Web" ("content_id", "url", "updated_at", "cache", "html_website") VALUES ('CACDA107-0597-4D8D-8F47-8E97CCBE3F8D', 'https://en.wikipedia.org/wiki/Biodiversity_of_Borneo', '1733830268.87031', NULL, NULL);
"""
	let user_notes = """
INSERT INTO "user_notes" ("content_id", "updated_at", "raw_text") VALUES ('E4AF1975-C7EC-4FD6-B3F2-CD0F6D4A2278', '1733780292.86625', 'Teak (Tectona grandis) is a tropical hardwood tree species in the family Lamiaceae. It is a large, deciduous tree that occurs in mixed hardwood forests. Tectona grandis has small, fragrant white flowers arranged in dense clusters (panicles) at the end of the branches. These flowers contain both types of reproductive organs (perfect flowers). The large, papery leaves of teak trees are often hairy on the lower surface. Teak wood has a leather-like smell when it is freshly milled and is particularly valued for its durability and water resistance. The wood is used for boat building, exterior construction, veneer, furniture, carving, turnings, and various small projects.');
INSERT INTO "user_notes" ("content_id", "updated_at", "raw_text") VALUES ('67F4BB75-C1AC-4E4E-8D9B-5D37DC8CD518', '1733780053.51714', 'Eusideroxylon is a genus of evergreen trees of the family Lauraceae. The genus is monotypic, and includes one accepted species, Eusideroxylon zwageri. It is known colloquially in English as Bornean ironwood, billian, or ulin.

It is native to Borneo and Sumatra, where it grows in lowland rain forests.

Eusideroxylon are hardwood trees reaching up to 50 metres in height with trunks over 2 metres (6 ft 7 in) in diameter, producing commercially valuable timber.[citation needed] The wood of E. zwageri is impervious to termites, and can last up to 100 years after being cut.[citation needed] Due to extensive logging, it is listed as vulnerable in the IUCN Red List.[1]

'); 
"""
	
	func eve_chat_message() throws -> String?{
		let eve_chat_array = [[
			"content": "Borneo is home to more diverse plant species than many other tropical areas. Some plants here are found nowhere else in the world.\nEnai can help you with this space by:\n- Organizing your findings into groups\n- Creating notes with facts and observations\n- Saving websites and articles for later reading\n- Allowing you to chat about specific information as you explore\n- Keeping your material organized for future reference",
			"role" : "assistant"
		]]
		let jsonData: Data = try JSONSerialization.data(withJSONObject: eve_chat_array, options: .prettyPrinted)
		return String(data: jsonData, encoding: .utf8)
	}
	
	
	let doc_table = """
INSERT INTO "document" ("id", "name", "owner", "shared", "created_at", "updated_at", "updated_by", "document") VALUES ('4D0CEF6E-9ECC-4B83-9A9B-F1CC249CAF92', 'Plants in Borneo', NULL, '0', '1733855208.51065', '1733855208.51065', NULL, '{
  "type" : "document",
  "data" : {
	"width" : {
	  "px" : 2560
	},
	"height" : {
	  "px" : 2835
	},
	"children" : [
	  {
		"data" : {
		  "state" : "sectionTitle",
		  "height" : {
			"px" : 57
		  },
		  "position" : {
			"y" : {
			  "px" : 107
			},
			"x" : {
			  "px" : 57
			},
			"posInViewStack" : 4
		  },
		  "width" : {
			"px" : 350
		  },
		  "children" : [

		  ],
		  "name" : "Rafflesia",
		  "id" : "C7700E88-B677-4ED6-851E-FB9F2B07F5FA"
		},
		"type" : "contentFrame"
	  },
	  {
		"data" : {
		  "state" : "expanded",
		  "height" : {
			"px" : 689.5
		  },
		  "width" : {
			"px" : 990
		  },
		  "children" : [
			{
			  "position" : 0,
			  "active" : true,
			  "id" : "C1AA772E-5E9E-4262-BD55-C8DA7338C066",
			  "contentState" : "loaded",
			  "contentType" : "eveChat"
			},
			{
			  "id" : "CACDA107-0597-4D8D-8F47-8E97CCBE3F8D",
			  "position" : 1,
			  "contentState" : "loaded",
			  "active" : false,
			  "contentType" : "web"
			}
		  ],
		  "position" : {
			"x" : {
			  "px" : 561
			},
			"y" : {
			  "px" : 100.5
			},
			"posInViewStack" : 15
		  },
		  "previousDisplayState" : {
			"state" : "minimised",
			"minimisedOrigin" : {
			  "y" : {
				"px" : 45
			  },
			  "x" : {
				"px" : 1202
			  }
			},
			"expandCollapseDirection" : "leftToRight",
			"defaultWindowOrigin" : {
			  "y" : {
				"px" : 45
			  },
			  "x" : {
				"px" : 492
			  }
			}
		  }
		},
		"type" : "contentFrame"
	  },
	  {
		"data" : {
		  "state" : "frameless",
		  "children" : [
			{
			  "active" : true,
			  "id" : "5CBD57A2-FDB6-41C7-B6C7-A6E69DDE9EFF",
			  "contentState" : "empty",
			  "contentType" : "img",
			  "position" : 0
			}
		  ],
		  "height" : {
			"px" : 467
		  },
		  "width" : {
			"px" : 350
		  },
		  "position" : {
			"x" : {
			  "px" : 17.5
			},
			"posInViewStack" : 2,
			"y" : {
			  "px" : 928.5
			}
		  }
		},
		"type" : "contentFrame"
	  },
	  {
		"type" : "contentFrame",
		"data" : {
		  "width" : {
			"px" : 714
		  },
		  "children" : [

		  ],
		  "state" : "sectionTitle",
		  "id" : "BC05D23A-5782-4845-8F06-AA9CE0E7AADC",
		  "height" : {
			"px" : 57
		  },
		  "name" : "Teak",
		  "position" : {
			"x" : {
			  "px" : 481.5
			},
			"y" : {
			  "px" : 1362.5
			},
			"posInViewStack" : 5
		  }
		}
	  },
	  {
		"type" : "contentFrame",
		"data" : {
		  "state" : "frameless",
		  "height" : {
			"px" : 374.5
		  },
		  "width" : {
			"px" : 375
		  },
		  "position" : {
			"y" : {
			  "px" : 1429
			},
			"posInViewStack" : 14,
			"x" : {
			  "px" : 891.5
			}
		  },
		  "children" : [
			{
			  "active" : true,
			  "position" : 0,
			  "contentState" : "empty",
			  "id" : "E4AF1975-C7EC-4FD6-B3F2-CD0F6D4A2278",
			  "contentType" : "note"
			}
		  ]
		}
	  },
	  {
		"type" : "contentFrame",
		"data" : {
		  "children" : [
			{
			  "contentType" : "img",
			  "contentState" : "empty",
			  "id" : "129B617E-3FBA-428C-BB57-91FBF2FE7613",
			  "active" : true,
			  "position" : 0
			}
		  ],
		  "position" : {
			"x" : {
			  "px" : 634.5
			},
			"y" : {
			  "px" : 992.5
			},
			"posInViewStack" : 9
		  },
		  "width" : {
			"px" : 439.5
		  },
		  "height" : {
			"px" : 330
		  },
		  "state" : "frameless"
		}
	  },
	  {
		"data" : {
		  "state" : "frameless",
		  "children" : [
			{
			  "contentType" : "img",
			  "contentState" : "empty",
			  "position" : 0,
			  "active" : true,
			  "id" : "36A7D9B2-6057-4F35-89FA-E30F89648AC7"
			}
		  ],
		  "position" : {
			"y" : {
			  "px" : 1850
			},
			"posInViewStack" : 1,
			"x" : {
			  "px" : 683
			}
		  },
		  "width" : {
			"px" : 440
		  },
		  "height" : {
			"px" : 293
		  }
		},
		"type" : "contentFrame"
	  },
	  {
		"data" : {
		  "height" : {
			"px" : 500
		  },
		  "position" : {
			"x" : {
			  "px" : 63
			},
			"y" : {
			  "px" : 169
			},
			"posInViewStack" : 8
		  },
		  "children" : [
			{
			  "position" : 0,
			  "id" : "459F9CE5-13F7-4AAE-B00F-C1ABF2CB8C24",
			  "contentState" : "empty",
			  "contentType" : "img",
			  "active" : true
			}
		  ],
		  "state" : "frameless",
		  "width" : {
			"px" : 333.5
		  }
		},
		"type" : "contentFrame"
	  },
	  {
		"data" : {
		  "state" : "frameless",
		  "height" : {
			"px" : 378
		  },
		  "children" : [
			{
			  "active" : true,
			  "contentType" : "note",
			  "contentState" : "empty",
			  "position" : 0,
			  "id" : "67F4BB75-C1AC-4E4E-8D9B-5D37DC8CD518"
			}
		  ],
		  "position" : {
			"y" : {
			  "px" : 944
			},
			"posInViewStack" : 11,
			"x" : {
			  "px" : 1098
			}
		  },
		  "width" : {
			"px" : 356
		  }
		},
		"type" : "contentFrame"
	  },
	  {
		"type" : "contentFrame",
		"data" : {
		  "position" : {
			"x" : {
			  "px" : 634
			},
			"y" : {
			  "px" : 865.5
			},
			"posInViewStack" : 6
		  },
		  "width" : {
			"px" : 829
		  },
		  "name" : "Ironwood (Eusideroxylon zwageri)",
		  "height" : {
			"px" : 57
		  },
		  "children" : [

		  ],
		  "state" : "sectionTitle",
		  "id" : "09215F6F-5D91-469F-A97C-D1EE9DDA0AF4"
		}
	  },
	  {
		"type" : "contentFrame",
		"data" : {
		  "height" : {
			"px" : 500
		  },
		  "position" : {
			"y" : {
			  "px" : 803.5
			},
			"posInViewStack" : 3,
			"x" : {
			  "px" : 79
			}
		  },
		  "children" : [
			{
			  "id" : "8125E0A3-62D3-4F4C-87E2-4B781329F29E",
			  "position" : 0,
			  "contentState" : "empty",
			  "contentType" : "img",
			  "active" : true
			}
		  ],
		  "state" : "frameless",
		  "width" : {
			"px" : 390.5
		  }
		}
	  },
	  {
		"type" : "contentFrame",
		"data" : {
		  "width" : {
			"px" : 469
		  },
		  "position" : {
			"x" : {
			  "px" : 11.5
			},
			"posInViewStack" : 7,
			"y" : {
			  "px" : 746
			}
		  },
		  "state" : "sectionTitle",
		  "height" : {
			"px" : 57
		  },
		  "name" : "Dipterocarps",
		  "children" : [

		  ],
		  "id" : "090ECBC2-1D69-4088-A36E-DE812186469F"
		}
	  },
	  {
		"data" : {
		  "state" : "frameless",
		  "width" : {
			"px" : 333.5
		  },
		  "position" : {
			"posInViewStack" : 12,
			"x" : {
			  "px" : 488
			},
			"y" : {
			  "px" : 1427.5
			}
		  },
		  "children" : [
			{
			  "contentState" : "empty",
			  "contentType" : "img",
			  "position" : 0,
			  "id" : "A6E48A0D-D220-4614-9B8E-963795BC4386",
			  "active" : true
			}
		  ],
		  "height" : {
			"px" : 500
		  }
		},
		"type" : "contentFrame"
	  },
	  {
		"type" : "contentFrame",
		"data" : {
		  "name" : "Ironwood",
		  "children" : [
			{
			  "position" : 0,
			  "contentState" : "loaded",
			  "active" : false,
			  "contentType" : "web",
			  "id" : "3FFE5183-18F3-4E15-90D2-4582A8D951EA"
			},
			{
			  "id" : "487317A2-B4F9-4609-81A8-729AB0AAFCE3",
			  "contentType" : "web",
			  "contentState" : "loaded",
			  "active" : false,
			  "position" : 1
			},
			{
			  "contentType" : "web",
			  "active" : true,
			  "position" : 2,
			  "contentState" : "loaded",
			  "id" : "B47892B0-5AC1-4B81-9BDD-5FBD4CF7DC81"
			}
		  ],
		  "id" : "BB01E5EC-D4EB-425D-85B7-76C897D5984F",
		  "position" : {
			"y" : {
			  "px" : 951.5
			},
			"posInViewStack" : 10,
			"x" : {
			  "px" : 764
			}
		  },
		  "previousDisplayState" : {
			"defaultWindowOrigin" : {
			  "x" : {
				"px" : 51.5
			  },
			  "y" : {
				"px" : 1119
			  }
			},
			"state" : "expanded",
			"minimisedOrigin" : {
			  "x" : {
				"px" : 932.5
			  },
			  "y" : {
				"px" : 1097.5
			  }
			},
			"expandCollapseDirection" : "leftToRight"
		  },
		  "width" : {
			"px" : 280
		  },
		  "height" : {
			"px" : 74
		  },
		  "state" : "collapsedMinimised"
		}
	  },
	  {
		"data" : {
		  "children" : [
			{
			  "id" : "C32FB10C-B080-4DC2-A529-E91ADE290581",
			  "active" : false,
			  "position" : 0,
			  "contentType" : "web",
			  "contentState" : "loaded"
			},
			{
			  "contentState" : "loaded",
			  "active" : false,
			  "contentType" : "web",
			  "position" : 1,
			  "id" : "7E06398B-FEDE-44F1-8D6A-6FF28384834C"
			},
			{
			  "active" : true,
			  "position" : 2,
			  "id" : "34E901A1-AD59-4167-BCDD-2C35139C5D4F",
			  "contentState" : "loaded",
			  "contentType" : "web"
			},
			{
			  "contentState" : "loaded",
			  "active" : false,
			  "id" : "A94C79A7-3D4B-4726-8C5A-6ADD144F5C38",
			  "contentType" : "web",
			  "position" : 3
			},
			{
			  "id" : "D8AEBF43-BAC6-450C-A468-00B2B9FBC80D",
			  "active" : false,
			  "position" : 4,
			  "contentState" : "loaded",
			  "contentType" : "web"
			},
			{
			  "active" : false,
			  "position" : 5,
			  "contentType" : "web",
			  "contentState" : "loaded",
			  "id" : "677F7F5B-FA94-4F0A-ACA3-BD31423391E8"
			}
		  ],
		  "position" : {
			"posInViewStack" : 13,
			"y" : {
			  "px" : 1638
			},
			"x" : {
			  "px" : 696.5
			}
		  },
		  "height" : {
			"px" : 74
		  },
		  "previousDisplayState" : {
			"state" : "minimised",
			"defaultWindowOrigin" : {
			  "y" : {
				"px" : 1509.5
			  },
			  "x" : {
				"px" : 174
			  }
			},
			"expandCollapseDirection" : "leftToRight",
			"minimisedOrigin" : {
			  "x" : {
				"px" : 696.5
			  },
			  "y" : {
				"px" : 1638
			  }
			}
		  },
		  "width" : {
			"px" : 280
		  },
		  "state" : "collapsedMinimised",
		  "name" : "Teak",
		  "id" : "800B3667-4A7C-4BCC-AD02-3F9D8AEACB9B"
		},
		"type" : "contentFrame"
	  }
	],
	"id" : "4D0CEF6E-9ECC-4B83-9A9B-F1CC249CAF92",
	"viewPosition" : {
	  "px" : 0
	}
  }
}');
"""
}
