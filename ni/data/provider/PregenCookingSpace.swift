//
//  PregenCookingSpace.swift
//  ni
//
//  Created by Patrick Lukas on 25/6/24.
//

import Foundation

class PregenCookingSpace{

	let content_sql = """
INSERT INTO "content" ("id", "title", "type", "updated_at", "local_storage_location", "ref_counter", "source_url") VALUES ('0A33A159-FE72-42F8-A8DB-B83E79DE710A', 'Green Bean Casserole — Alison Roman', 'web', '1719338454.61125', '', '1', '');
INSERT INTO "content" ("id", "title", "type", "updated_at", "local_storage_location", "ref_counter", "source_url") VALUES ('1121EC8E-1CE0-4E96-B831-5D11E0F57E32', 'food of the western fronteir - Google Search', 'web', '1719338454.60103', '', '1', '');
INSERT INTO "content" ("id", "title", "type", "updated_at", "local_storage_location", "ref_counter", "source_url") VALUES ('11C5EE45-B783-4FD0-B86B-0931E40196EA', 'Halloumi salad with orange & mint recipe | Good Food', 'web', '1719338454.61993', '', '1', '');
INSERT INTO "content" ("id", "title", "type", "updated_at", "local_storage_location", "ref_counter", "source_url") VALUES ('17AC6C87-BD2F-483E-8932-2B91182108E2', 'What Did They Eat in the Wild West? Making Buffalo Stew & Churning Butter From Scratch — Savor Tooth Tiger', 'web', '1719338454.60567', '', '1', '');
INSERT INTO "content" ("id", "title", "type", "updated_at", "local_storage_location", "ref_counter", "source_url") VALUES ('1956344A-40E5-4DD3-97CE-E43190A3AE96', 'Grilled Halloumi Cheese Recipe - Love and Lemons', 'web', '1719338454.62061', '', '1', '');
INSERT INTO "content" ("id", "title", "type", "updated_at", "local_storage_location", "ref_counter", "source_url") VALUES ('259E1F69-E675-458B-967A-2C12B75C528A', 'How to Cut an Onion - The New York Times', 'web', '1719338454.61523', '', '1', '');
INSERT INTO "content" ("id", "title", "type", "updated_at", "local_storage_location", "ref_counter", "source_url") VALUES ('333B8F8B-1B7F-415A-BD24-9D9BC4CAF5F5', 'Mediterranean Tomato and Halloumi Bake', 'web', '1715361973.82515', '', '1', '');
INSERT INTO "content" ("id", "title", "type", "updated_at", "local_storage_location", "ref_counter", "source_url") VALUES ('36B60973-8060-4C82-AD88-C1674EB9BAEA', 'Our Taste For Turtle Soup Nearly Wiped Out Terrapins. Then Prohibition Saved Them : The Salt : NPR', 'web', '1719338454.60387', '', '1', '');
INSERT INTO "content" ("id", "title", "type", "updated_at", "local_storage_location", "ref_counter", "source_url") VALUES ('39C04FD8-CCE4-41DD-89C5-74BE981BE9A4', 'What are different versions of mirepoix? : r/Cooking', 'web', '1719338454.6323', '', '1', '');
INSERT INTO "content" ("id", "title", "type", "updated_at", "local_storage_location", "ref_counter", "source_url") VALUES ('3D3F9ACE-543D-449B-8772-86948BBAC9AC', 'weather berlin - Google Search', 'web', '1719338454.62829', '', '1', '');
INSERT INTO "content" ("id", "title", "type", "updated_at", "local_storage_location", "ref_counter", "source_url") VALUES ('421B3C49-0DB0-4940-AFD4-89427284112A', 'chicken and rice kenji - Google Search', 'web', '1714918599.78052', '', '1', '');
INSERT INTO "content" ("id", "title", "type", "updated_at", "local_storage_location", "ref_counter", "source_url") VALUES ('48FBAF42-9B5B-4797-88F6-660A9F49820E', 'Mirepoix - Wikipedia', 'web', '1719338454.63106', '', '1', '');
INSERT INTO "content" ("id", "title", "type", "updated_at", "local_storage_location", "ref_counter", "source_url") VALUES ('490242B8-8AC3-445A-947F-7510B212744A', 'Labne with Sizzled Scallions and Chile — Alison Roman', 'web', '1719338454.61038', '', '1', '');
INSERT INTO "content" ("id", "title", "type", "updated_at", "local_storage_location", "ref_counter", "source_url") VALUES ('55C16471-F3C0-4096-94AF-5CB06B07704B', 'YouTube', 'web', '1719338454.6065', '', '1', '');
INSERT INTO "content" ("id", "title", "type", "updated_at", "local_storage_location", "ref_counter", "source_url") VALUES ('5824925C-94DB-4F9B-8094-347308394739', 'All About Mirepoix, Sofrito, Battuto, and Other Humble Beginnings', 'web', '1719338454.63293', '', '1', '');
INSERT INTO "content" ("id", "title", "type", "updated_at", "local_storage_location", "ref_counter", "source_url") VALUES ('642AE5AB-866B-4215-944F-78C25D3C223C', 'Lemony Broccoli Salad With Halloumi Cheese – Precious Time Blog', 'web', '1719338454.61775', '', '1', '');
INSERT INTO "content" ("id", "title", "type", "updated_at", "local_storage_location", "ref_counter", "source_url") VALUES ('6E9350AF-E4CB-4F87-80D7-447314D5797D', 'halloumi with broccoli - Google Search', 'web', '1719338454.61694', '', '1', '');
INSERT INTO "content" ("id", "title", "type", "updated_at", "local_storage_location", "ref_counter", "source_url") VALUES ('71855E5C-D0F6-4BD7-ADE2-1656BDE6DA70', 'Halloumi fajitas recipe | Good Food', 'web', '1715361973.82841', '', '1', '');
INSERT INTO "content" ("id", "title", "type", "updated_at", "local_storage_location", "ref_counter", "source_url") VALUES ('72F6FA20-AA1B-4755-B43B-6EB7440A25BC', 'bolognese recipe - Google Search', 'web', '1719338454.62145', '', '1', '');
INSERT INTO "content" ("id", "title", "type", "updated_at", "local_storage_location", "ref_counter", "source_url") VALUES ('7391FD3B-05CA-4BEE-9735-B15C5533AD04', 'A solution to the Onion Problem of J. Kenji López-Alt | by Dylan Poulsen | Medium', 'web', '1719338454.6145', '', '1', '');
INSERT INTO "content" ("id", "title", "type", "updated_at", "local_storage_location", "ref_counter", "source_url") VALUES ('7ED714E2-0628-41A8-B28A-ADF45BC17E95', 'Serious Eats'' Halal Cart-Style Chicken and Rice With White Sauce ', 'web', '1714918599.78483', '', '1', '');
INSERT INTO "content" ("id", "title", "type", "updated_at", "local_storage_location", "ref_counter", "source_url") VALUES ('8700ED25-C51D-4C4D-A1CA-72CEA23D27FF', 'What Pioneers Ate', 'web', '1719338454.60478', '', '1', '');
INSERT INTO "content" ("id", "title", "type", "updated_at", "local_storage_location", "ref_counter", "source_url") VALUES ('8C6DCB17-F26F-4A02-9860-306D6B9B3231', 'Cuisine of Antebellum America - Wikipedia', 'web', '1719338454.60284', '', '1', '');
INSERT INTO "content" ("id", "title", "type", "updated_at", "local_storage_location", "ref_counter", "source_url") VALUES ('8D44F7BE-F135-4969-9420-69CFFF83ECED', 'Access to this page has been denied.', 'web', '1719338454.62356', '', '1', '');
INSERT INTO "content" ("id", "title", "type", "updated_at", "local_storage_location", "ref_counter", "source_url") VALUES ('8FE9F792-066C-4DCD-A63F-A0F060511345', 'Sofrito - Wikipedia', 'web', '1719338454.62896', '', '1', '');
INSERT INTO "content" ("id", "title", "type", "updated_at", "local_storage_location", "ref_counter", "source_url") VALUES ('94E207BD-8095-4714-8246-8F8E7BA9B238', 'A Beginner''s Guide to Onions', 'web', '1719338454.61603', '', '1', '');
INSERT INTO "content" ("id", "title", "type", "updated_at", "local_storage_location", "ref_counter", "source_url") VALUES ('96943890-729F-489F-B5C2-1E72CE942DAA', 'Halloumi fajitas recipe | Good Food', 'web', '1715361873.00704', '', '1', '');
INSERT INTO "content" ("id", "title", "type", "updated_at", "local_storage_location", "ref_counter", "source_url") VALUES ('9E00074B-94BB-404E-8856-26A3AF13E090', 'Spinach & halloumi salad recipe | Good Food', 'web', '1719338454.61926', '', '1', '');
INSERT INTO "content" ("id", "title", "type", "updated_at", "local_storage_location", "ref_counter", "source_url") VALUES ('A6D7749F-D014-4093-9C1F-0E21C317C361', 'marcella hazan bolognese - Google Search', 'web', '1719338454.62216', '', '1', '');
INSERT INTO "content" ("id", "title", "type", "updated_at", "local_storage_location", "ref_counter", "source_url") VALUES ('AD356BEC-5C3A-46FD-B70E-0F521E4E0E31', 'Holy trinity (cooking) - Wikipedia', 'web', '1719338454.63041', '', '1', '');
INSERT INTO "content" ("id", "title", "type", "updated_at", "local_storage_location", "ref_counter", "source_url") VALUES ('AF32C11F-BBC4-47AB-8A31-B25D64659636', 'Very Crunchy Salad feat. Fennel, Apples, and Pecans — Alison Roman', 'web', '1719338454.60951', '', '1', '');
INSERT INTO "content" ("id", "title", "type", "updated_at", "local_storage_location", "ref_counter", "source_url") VALUES ('B31464A1-E987-41A7-89A6-61205FD4E1BD', 'Marcella Hazan''s Bolognese - A Beautiful Plate', 'web', '1719338454.62423', '', '1', '');
INSERT INTO "content" ("id", "title", "type", "updated_at", "local_storage_location", "ref_counter", "source_url") VALUES ('B86FE905-F89B-4FC5-91F9-34FA821F1341', 'Roasted Bok Choy Recipe', 'web', '1714917366.74833', '', '1', '');
INSERT INTO "content" ("id", "title", "type", "updated_at", "local_storage_location", "ref_counter", "source_url") VALUES ('B8B5B87D-3779-4616-877A-933A89082D2E', 'Brothy Chickpeas with Calabrian Chili — Alison Roman', 'web', '1719338454.60866', '', '1', '');
INSERT INTO "content" ("id", "title", "type", "updated_at", "local_storage_location", "ref_counter", "source_url") VALUES ('BC932DC6-C8A9-4876-A5FC-95B52D89E58B', 'mirepoix variations - Google Search', 'web', '1719338454.63167', '', '1', '');
INSERT INTO "content" ("id", "title", "type", "updated_at", "local_storage_location", "ref_counter", "source_url") VALUES ('C0EC3AF0-01BD-4509-A8D9-FC4A7A0CBD2C', 'Epis - Wikipedia', 'web', '1719338454.62979', '', '1', '');
INSERT INTO "content" ("id", "title", "type", "updated_at", "local_storage_location", "ref_counter", "source_url") VALUES ('C11E649A-CBE3-45DB-B627-DAFC260F67C3', 'Spaghetti Bolognese - RecipeTin Eats', 'web', '1719338454.62557', '', '1', '');
INSERT INTO "content" ("id", "title", "type", "updated_at", "local_storage_location", "ref_counter", "source_url") VALUES ('C1B014B6-4CE6-4D84-88FC-03CE52A1405F', 'A solution to the Onion Problem of J. Kenji López-Alt | by Dylan Poulsen | Medium', 'web', '1719338454.61373', '', '1', '');
INSERT INTO "content" ("id", "title", "type", "updated_at", "local_storage_location", "ref_counter", "source_url") VALUES ('C5570FCB-55A6-48B0-B707-75F88F1AE897', 'Die echte Sauce Bolognese von tillek| Chefkoch', 'web', '1719338454.62625', '', '1', '');
INSERT INTO "content" ("id", "title", "type", "updated_at", "local_storage_location", "ref_counter", "source_url") VALUES ('CDC67AE9-E637-4035-971F-374498AAAE3B', 'Halloumi Salad Recipes | Good Food', 'web', '1719338454.61851', '', '1', '');
INSERT INTO "content" ("id", "title", "type", "updated_at", "local_storage_location", "ref_counter", "source_url") VALUES ('D1EDF87B-1D23-41A9-B0E3-5C0FE48AD4EF', 'Pasta Bolognese recipe', 'web', '1719338454.6229', '', '1', '');
INSERT INTO "content" ("id", "title", "type", "updated_at", "local_storage_location", "ref_counter", "source_url") VALUES ('DB5074A7-3B0E-4C4C-89CF-C1A963EDF5AC', 'how to cut an onion kenji - Google Search', 'web', '1719338454.61294', '', '1', '');
INSERT INTO "content" ("id", "title", "type", "updated_at", "local_storage_location", "ref_counter", "source_url") VALUES ('E4B76C73-9CD8-41D1-9B0A-92E16A198FE3', 'Recipes — Alison Roman', 'web', '1719338454.60758', '', '1', '');
INSERT INTO "content" ("id", "title", "type", "updated_at", "local_storage_location", "ref_counter", "source_url") VALUES ('E4B7CEFB-EEAC-4AF9-82AF-3DED94331656', 'Pasta Bolognese Recipe', 'web', '1719338454.6249', '', '1', '');
INSERT INTO "content" ("id", "title", "type", "updated_at", "local_storage_location", "ref_counter", "source_url") VALUES ('F35FC52D-2673-4899-9E30-8712FE2C97B6', 'Easy Bolognese Sauce Recipe - YouTube', 'web', '1719338454.6276', '', '1', '');
INSERT INTO "content" ("id", "title", "type", "updated_at", "local_storage_location", "ref_counter", "source_url") VALUES ('FC067D67-CCA7-4980-9B3E-E011778A19D2', 'Spicy Chicken Piccata — Alison Roman', 'web', '1719338454.61203', '', '1', '');
"""
	let doc_content_sql = """
INSERT INTO "doc_id_content_id" ("document_id", "content_id") VALUES ('4D90F0F2-064D-42B8-9A16-B9A613A2A162', '0A33A159-FE72-42F8-A8DB-B83E79DE710A');
INSERT INTO "doc_id_content_id" ("document_id", "content_id") VALUES ('4D90F0F2-064D-42B8-9A16-B9A613A2A162', '1121EC8E-1CE0-4E96-B831-5D11E0F57E32');
INSERT INTO "doc_id_content_id" ("document_id", "content_id") VALUES ('4D90F0F2-064D-42B8-9A16-B9A613A2A162', '11C5EE45-B783-4FD0-B86B-0931E40196EA');
INSERT INTO "doc_id_content_id" ("document_id", "content_id") VALUES ('4D90F0F2-064D-42B8-9A16-B9A613A2A162', '17AC6C87-BD2F-483E-8932-2B91182108E2');
INSERT INTO "doc_id_content_id" ("document_id", "content_id") VALUES ('4D90F0F2-064D-42B8-9A16-B9A613A2A162', '1956344A-40E5-4DD3-97CE-E43190A3AE96');
INSERT INTO "doc_id_content_id" ("document_id", "content_id") VALUES ('4D90F0F2-064D-42B8-9A16-B9A613A2A162', '259E1F69-E675-458B-967A-2C12B75C528A');
INSERT INTO "doc_id_content_id" ("document_id", "content_id") VALUES ('4D90F0F2-064D-42B8-9A16-B9A613A2A162', '333B8F8B-1B7F-415A-BD24-9D9BC4CAF5F5');
INSERT INTO "doc_id_content_id" ("document_id", "content_id") VALUES ('4D90F0F2-064D-42B8-9A16-B9A613A2A162', '36B60973-8060-4C82-AD88-C1674EB9BAEA');
INSERT INTO "doc_id_content_id" ("document_id", "content_id") VALUES ('4D90F0F2-064D-42B8-9A16-B9A613A2A162', '39C04FD8-CCE4-41DD-89C5-74BE981BE9A4');
INSERT INTO "doc_id_content_id" ("document_id", "content_id") VALUES ('4D90F0F2-064D-42B8-9A16-B9A613A2A162', '3D3F9ACE-543D-449B-8772-86948BBAC9AC');
INSERT INTO "doc_id_content_id" ("document_id", "content_id") VALUES ('4D90F0F2-064D-42B8-9A16-B9A613A2A162', '421B3C49-0DB0-4940-AFD4-89427284112A');
INSERT INTO "doc_id_content_id" ("document_id", "content_id") VALUES ('4D90F0F2-064D-42B8-9A16-B9A613A2A162', '48FBAF42-9B5B-4797-88F6-660A9F49820E');
INSERT INTO "doc_id_content_id" ("document_id", "content_id") VALUES ('4D90F0F2-064D-42B8-9A16-B9A613A2A162', '490242B8-8AC3-445A-947F-7510B212744A');
INSERT INTO "doc_id_content_id" ("document_id", "content_id") VALUES ('4D90F0F2-064D-42B8-9A16-B9A613A2A162', '55C16471-F3C0-4096-94AF-5CB06B07704B');
INSERT INTO "doc_id_content_id" ("document_id", "content_id") VALUES ('4D90F0F2-064D-42B8-9A16-B9A613A2A162', '5824925C-94DB-4F9B-8094-347308394739');
INSERT INTO "doc_id_content_id" ("document_id", "content_id") VALUES ('4D90F0F2-064D-42B8-9A16-B9A613A2A162', '642AE5AB-866B-4215-944F-78C25D3C223C');
INSERT INTO "doc_id_content_id" ("document_id", "content_id") VALUES ('4D90F0F2-064D-42B8-9A16-B9A613A2A162', '6E9350AF-E4CB-4F87-80D7-447314D5797D');
INSERT INTO "doc_id_content_id" ("document_id", "content_id") VALUES ('4D90F0F2-064D-42B8-9A16-B9A613A2A162', '71855E5C-D0F6-4BD7-ADE2-1656BDE6DA70');
INSERT INTO "doc_id_content_id" ("document_id", "content_id") VALUES ('4D90F0F2-064D-42B8-9A16-B9A613A2A162', '72F6FA20-AA1B-4755-B43B-6EB7440A25BC');
INSERT INTO "doc_id_content_id" ("document_id", "content_id") VALUES ('4D90F0F2-064D-42B8-9A16-B9A613A2A162', '7391FD3B-05CA-4BEE-9735-B15C5533AD04');
INSERT INTO "doc_id_content_id" ("document_id", "content_id") VALUES ('4D90F0F2-064D-42B8-9A16-B9A613A2A162', '7ED714E2-0628-41A8-B28A-ADF45BC17E95');
INSERT INTO "doc_id_content_id" ("document_id", "content_id") VALUES ('4D90F0F2-064D-42B8-9A16-B9A613A2A162', '8700ED25-C51D-4C4D-A1CA-72CEA23D27FF');
INSERT INTO "doc_id_content_id" ("document_id", "content_id") VALUES ('4D90F0F2-064D-42B8-9A16-B9A613A2A162', '8C6DCB17-F26F-4A02-9860-306D6B9B3231');
INSERT INTO "doc_id_content_id" ("document_id", "content_id") VALUES ('4D90F0F2-064D-42B8-9A16-B9A613A2A162', '8D44F7BE-F135-4969-9420-69CFFF83ECED');
INSERT INTO "doc_id_content_id" ("document_id", "content_id") VALUES ('4D90F0F2-064D-42B8-9A16-B9A613A2A162', '8FE9F792-066C-4DCD-A63F-A0F060511345');
INSERT INTO "doc_id_content_id" ("document_id", "content_id") VALUES ('4D90F0F2-064D-42B8-9A16-B9A613A2A162', '94E207BD-8095-4714-8246-8F8E7BA9B238');
INSERT INTO "doc_id_content_id" ("document_id", "content_id") VALUES ('4D90F0F2-064D-42B8-9A16-B9A613A2A162', '96943890-729F-489F-B5C2-1E72CE942DAA');
INSERT INTO "doc_id_content_id" ("document_id", "content_id") VALUES ('4D90F0F2-064D-42B8-9A16-B9A613A2A162', '9E00074B-94BB-404E-8856-26A3AF13E090');
INSERT INTO "doc_id_content_id" ("document_id", "content_id") VALUES ('4D90F0F2-064D-42B8-9A16-B9A613A2A162', 'A6D7749F-D014-4093-9C1F-0E21C317C361');
INSERT INTO "doc_id_content_id" ("document_id", "content_id") VALUES ('4D90F0F2-064D-42B8-9A16-B9A613A2A162', 'AD356BEC-5C3A-46FD-B70E-0F521E4E0E31');
INSERT INTO "doc_id_content_id" ("document_id", "content_id") VALUES ('4D90F0F2-064D-42B8-9A16-B9A613A2A162', 'AF32C11F-BBC4-47AB-8A31-B25D64659636');
INSERT INTO "doc_id_content_id" ("document_id", "content_id") VALUES ('4D90F0F2-064D-42B8-9A16-B9A613A2A162', 'B31464A1-E987-41A7-89A6-61205FD4E1BD');
INSERT INTO "doc_id_content_id" ("document_id", "content_id") VALUES ('4D90F0F2-064D-42B8-9A16-B9A613A2A162', 'B86FE905-F89B-4FC5-91F9-34FA821F1341');
INSERT INTO "doc_id_content_id" ("document_id", "content_id") VALUES ('4D90F0F2-064D-42B8-9A16-B9A613A2A162', 'B8B5B87D-3779-4616-877A-933A89082D2E');
INSERT INTO "doc_id_content_id" ("document_id", "content_id") VALUES ('4D90F0F2-064D-42B8-9A16-B9A613A2A162', 'BC932DC6-C8A9-4876-A5FC-95B52D89E58B');
INSERT INTO "doc_id_content_id" ("document_id", "content_id") VALUES ('4D90F0F2-064D-42B8-9A16-B9A613A2A162', 'C0EC3AF0-01BD-4509-A8D9-FC4A7A0CBD2C');
INSERT INTO "doc_id_content_id" ("document_id", "content_id") VALUES ('4D90F0F2-064D-42B8-9A16-B9A613A2A162', 'C11E649A-CBE3-45DB-B627-DAFC260F67C3');
INSERT INTO "doc_id_content_id" ("document_id", "content_id") VALUES ('4D90F0F2-064D-42B8-9A16-B9A613A2A162', 'C1B014B6-4CE6-4D84-88FC-03CE52A1405F');
INSERT INTO "doc_id_content_id" ("document_id", "content_id") VALUES ('4D90F0F2-064D-42B8-9A16-B9A613A2A162', 'C5570FCB-55A6-48B0-B707-75F88F1AE897');
INSERT INTO "doc_id_content_id" ("document_id", "content_id") VALUES ('4D90F0F2-064D-42B8-9A16-B9A613A2A162', 'CDC67AE9-E637-4035-971F-374498AAAE3B');
INSERT INTO "doc_id_content_id" ("document_id", "content_id") VALUES ('4D90F0F2-064D-42B8-9A16-B9A613A2A162', 'D1EDF87B-1D23-41A9-B0E3-5C0FE48AD4EF');
INSERT INTO "doc_id_content_id" ("document_id", "content_id") VALUES ('4D90F0F2-064D-42B8-9A16-B9A613A2A162', 'DB5074A7-3B0E-4C4C-89CF-C1A963EDF5AC');
INSERT INTO "doc_id_content_id" ("document_id", "content_id") VALUES ('4D90F0F2-064D-42B8-9A16-B9A613A2A162', 'E4B76C73-9CD8-41D1-9B0A-92E16A198FE3');
INSERT INTO "doc_id_content_id" ("document_id", "content_id") VALUES ('4D90F0F2-064D-42B8-9A16-B9A613A2A162', 'E4B7CEFB-EEAC-4AF9-82AF-3DED94331656');
INSERT INTO "doc_id_content_id" ("document_id", "content_id") VALUES ('4D90F0F2-064D-42B8-9A16-B9A613A2A162', 'F35FC52D-2673-4899-9E30-8712FE2C97B6');
INSERT INTO "doc_id_content_id" ("document_id", "content_id") VALUES ('4D90F0F2-064D-42B8-9A16-B9A613A2A162', 'FC067D67-CCA7-4980-9B3E-E011778A19D2');
"""
	
	let cached_web_sql = """
INSERT INTO "cached_Web" ("content_id", "url", "updated_at", "cache", "html_website") VALUES ('0A33A159-FE72-42F8-A8DB-B83E79DE710A', 'https://www.alisoneroman.com/recipes/green-bean-casserole', '1719338454.61163', '', '');
INSERT INTO "cached_Web" ("content_id", "url", "updated_at", "cache", "html_website") VALUES ('1121EC8E-1CE0-4E96-B831-5D11E0F57E32', 'https://www.google.com/search?q=food%20of%20the%20western%20fronteir', '1719338454.60205', '', '');
INSERT INTO "cached_Web" ("content_id", "url", "updated_at", "cache", "html_website") VALUES ('11C5EE45-B783-4FD0-B86B-0931E40196EA', 'https://www.bbcgoodfood.com/recipes/halloumi-salad-orange-mint', '1719338454.62025', '', '');
INSERT INTO "cached_Web" ("content_id", "url", "updated_at", "cache", "html_website") VALUES ('17AC6C87-BD2F-483E-8932-2B91182108E2', 'https://www.savortoothtiger.com/recipes/wild-west', '1719338454.60606', '', '');
INSERT INTO "cached_Web" ("content_id", "url", "updated_at", "cache", "html_website") VALUES ('1956344A-40E5-4DD3-97CE-E43190A3AE96', 'https://www.loveandlemons.com/grilled-halloumi-cheese/', '1719338454.62109', '', '');
INSERT INTO "cached_Web" ("content_id", "url", "updated_at", "cache", "html_website") VALUES ('259E1F69-E675-458B-967A-2C12B75C528A', 'https://www.nytimes.com/article/how-to-cut-onion.html', '1719338454.6156', '', '');
INSERT INTO "cached_Web" ("content_id", "url", "updated_at", "cache", "html_website") VALUES ('333B8F8B-1B7F-415A-BD24-9D9BC4CAF5F5', 'https://www.tamingtwins.com/grilled-halloumi-cheese-bake-recipe/', '1715457664.07058', '', '');
INSERT INTO "cached_Web" ("content_id", "url", "updated_at", "cache", "html_website") VALUES ('36B60973-8060-4C82-AD88-C1674EB9BAEA', 'https://www.npr.org/sections/thesalt/2019/07/18/742326830/our-taste-for-turtle-soup-nearly-wiped-out-terrapins-then-prohibition-saved-them', '1719338454.60429', '', '');
INSERT INTO "cached_Web" ("content_id", "url", "updated_at", "cache", "html_website") VALUES ('39C04FD8-CCE4-41DD-89C5-74BE981BE9A4', 'https://www.reddit.com/r/Cooking/comments/5mnsex/what_are_different_versions_of_mirepoix/', '1719338454.63261', '', '');
INSERT INTO "cached_Web" ("content_id", "url", "updated_at", "cache", "html_website") VALUES ('3D3F9ACE-543D-449B-8772-86948BBAC9AC', 'https://www.google.com/search?q=weather%20berlin', '1719338454.62862', '', '');
INSERT INTO "cached_Web" ("content_id", "url", "updated_at", "cache", "html_website") VALUES ('421B3C49-0DB0-4940-AFD4-89427284112A', 'https://www.google.com/search?q=chicken+and+rice+kenji&sca_esv=7ed003f8ae5288af&sxsrf=ADLYWIIUoxq3jc79OL_r2Jh1m_JpqqNHag%3A1714918465009&ei=QJQ3ZuXyPIaE9u8Ph4GZCA&ved=0ahUKEwjlkrOP2faFAxUGgv0HHYdABgEQ4dUDCBA&uact=5&oq=chicken+and+rice+kenji&gs_lp=Egxnd3Mtd2l6LXNlcnAiFmNoaWNrZW4gYW5kIHJpY2Uga2VuamkyBRAAGIAEMgYQABgWGB4yBhAAGBYYHjILEAAYgAQYhgMYigUyCxAAGIAEGIYDGIoFMgsQABiABBiGAxiKBTIIEAAYgAQYogRIzw1QhQVYywtwAXgBkAEAmAGQAaABvQWqAQMwLja4AQPIAQD4AQGYAgegAuAFwgIHECMYsAMYJ8ICChAAGLADGNYEGEfCAgoQIxiABBgnGIoFwgIKEAAYgAQYQxiKBcICChAAGIAEGBQYhwLCAggQABgWGB4YD5gDAIgGAZAGCpIHAzEuNqAHkiY&sclient=gws-wiz-serp', '1715457664.07197', '', '');
INSERT INTO "cached_Web" ("content_id", "url", "updated_at", "cache", "html_website") VALUES ('48FBAF42-9B5B-4797-88F6-660A9F49820E', 'https://en.wikipedia.org/wiki/Mirepoix', '1719338454.63135', '', '');
INSERT INTO "cached_Web" ("content_id", "url", "updated_at", "cache", "html_website") VALUES ('490242B8-8AC3-445A-947F-7510B212744A', 'https://www.alisoneroman.com/recipes/labne-with-sizzled-scallions-and-chile', '1719338454.61078', '', '');
INSERT INTO "cached_Web" ("content_id", "url", "updated_at", "cache", "html_website") VALUES ('55C16471-F3C0-4096-94AF-5CB06B07704B', 'https://www.youtube.com/', '1719338454.60691', '', '');
INSERT INTO "cached_Web" ("content_id", "url", "updated_at", "cache", "html_website") VALUES ('5824925C-94DB-4F9B-8094-347308394739', 'https://www.seriouseats.com/all-about-mirepoix', '1719338454.63323', '', '');
INSERT INTO "cached_Web" ("content_id", "url", "updated_at", "cache", "html_website") VALUES ('642AE5AB-866B-4215-944F-78C25D3C223C', 'https://precioustimeblog.com/lemony-broccoli-salad-with-halloumi-cheese/', '1719338454.6181', '', '');
INSERT INTO "cached_Web" ("content_id", "url", "updated_at", "cache", "html_website") VALUES ('6E9350AF-E4CB-4F87-80D7-447314D5797D', 'https://www.google.com/search?q=halloumi+with+broccoli&sca_esv=3da76239dbcc3be6&sxsrf=ADLYWIJACOLMd-XaiiqBnS713E_Il0eJnA%3A1719067600912&ei=0ON2ZrSjN-DaptQPq8GxyAs&ved=0ahUKEwi0y8ntue-GAxVgrYkEHatgDLkQ4dUDCBA&uact=5&oq=halloumi+with+broccoli&gs_lp=Egxnd3Mtd2l6LXNlcnAiFmhhbGxvdW1pIHdpdGggYnJvY2NvbGkyBRAAGIAEMgYQABgWGB4yBhAAGBYYHjIGEAAYFhgeMgYQABgWGB4yBhAAGBYYHjIGEAAYFhgeMgYQABgWGB4yBhAAGBYYHjIGEAAYFhgeSLkgUN0QWOQecAR4AZABAJgBuQGgAaERqgEEMC4xM7gBA8gBAPgBAZgCEKAC5RDCAgcQIxiwAxgnwgIKEAAYsAMY1gQYR8ICDRAAGIAEGLADGEMYigXCAg4QABiwAxjkAhjWBNgBAcICExAuGIAEGLADGEMYyAMYigXYAQLCAhYQLhiABBiwAxhDGNQCGMgDGIoF2AECwgILEAAYgAQYkQIYigWYAwCIBgGQBhK6BgYIARABGAm6BgYIAhABGAiSBwQ0LjEyoAfpSw&sclient=gws-wiz-serp', '1719338454.61732', '', '');
INSERT INTO "cached_Web" ("content_id", "url", "updated_at", "cache", "html_website") VALUES ('71855E5C-D0F6-4BD7-ADE2-1656BDE6DA70', 'https://www.bbcgoodfood.com/recipes/halloumi-fajitas', '1715457664.07104', '', '');
INSERT INTO "cached_Web" ("content_id", "url", "updated_at", "cache", "html_website") VALUES ('72F6FA20-AA1B-4755-B43B-6EB7440A25BC', 'https://www.google.com/search?q=bolognese+recipe&sca_esv=5117588ff0c2eced&sxsrf=ADLYWIKV_V6y72SsNPoBym317giLlWInBg%3A1716645370359&ei=-u1RZpm8FfiE9u8PlvGS8Ak&ved=0ahUKEwiZoYWs-qiGAxV4gv0HHZa4BJ4Q4dUDCBA&uact=5&oq=bolognese+recipe&gs_lp=Egxnd3Mtd2l6LXNlcnAiEGJvbG9nbmVzZSByZWNpcGUyBRAAGIAEMgUQABiABDIFEAAYgAQyBRAAGIAEMgUQABiABDIFEAAYgAQyBRAAGIAEMgUQABiABDIFEAAYgAQyBRAAGIAESIIOUPoGWPQMcAF4AZABAJgBaaABhAWqAQM0LjO4AQPIAQD4AQGYAgigAqMFwgIKEAAYsAMY1gQYR8ICDRAAGIAEGLADGEMYigXCAgoQABiABBhDGIoFwgIKEC4YgAQYQxiKBcICBRAuGIAEmAMAiAYBkAYKkgcDNS4zoAfcMg&sclient=gws-wiz-serp', '1719338454.62179', '', '');
INSERT INTO "cached_Web" ("content_id", "url", "updated_at", "cache", "html_website") VALUES ('7391FD3B-05CA-4BEE-9735-B15C5533AD04', 'https://medium.com/@drspoulsen/a-solution-to-the-onion-problem-of-j-kenji-l%C3%B3pez-alt-c3c4ab22e67c', '1719338454.61484', '', '');
INSERT INTO "cached_Web" ("content_id", "url", "updated_at", "cache", "html_website") VALUES ('7ED714E2-0628-41A8-B28A-ADF45BC17E95', 'https://www.seriouseats.com/serious-eats-halal-cart-style-chicken-and-rice-white-sauce-recipe', '1715457664.07242', '', '');
INSERT INTO "cached_Web" ("content_id", "url", "updated_at", "cache", "html_website") VALUES ('8700ED25-C51D-4C4D-A1CA-72CEA23D27FF', 'https://www.notesfromthefrontier.com/post/what-pioneers-ate', '1719338454.6052', '', '');
INSERT INTO "cached_Web" ("content_id", "url", "updated_at", "cache", "html_website") VALUES ('8C6DCB17-F26F-4A02-9860-306D6B9B3231', 'https://en.wikipedia.org/wiki/Cuisine_of_Antebellum_America', '1719338454.60336', '', '');
INSERT INTO "cached_Web" ("content_id", "url", "updated_at", "cache", "html_website") VALUES ('8D44F7BE-F135-4969-9420-69CFFF83ECED', 'https://www.thekitchn.com/marcella-hazans-amazing-4ingre-144538', '1719338454.62387', '', '');
INSERT INTO "cached_Web" ("content_id", "url", "updated_at", "cache", "html_website") VALUES ('8FE9F792-066C-4DCD-A63F-A0F060511345', 'https://en.wikipedia.org/wiki/Sofrito', '1719338454.62926', '', '');
INSERT INTO "cached_Web" ("content_id", "url", "updated_at", "cache", "html_website") VALUES ('94E207BD-8095-4714-8246-8F8E7BA9B238', 'https://www.seriouseats.com/differences-between-onions', '1719338454.6164', '', '');
INSERT INTO "cached_Web" ("content_id", "url", "updated_at", "cache", "html_website") VALUES ('96943890-729F-489F-B5C2-1E72CE942DAA', 'https://www.google.com/search?q=halloumi%20fajitas', '1715457664.07008', '', '');
INSERT INTO "cached_Web" ("content_id", "url", "updated_at", "cache", "html_website") VALUES ('9E00074B-94BB-404E-8856-26A3AF13E090', 'https://www.bbcgoodfood.com/recipes/spinach-halloumi-salad', '1719338454.61957', '', '');
INSERT INTO "cached_Web" ("content_id", "url", "updated_at", "cache", "html_website") VALUES ('A6D7749F-D014-4093-9C1F-0E21C317C361', 'https://www.google.com/search?q=marcella%20hazan%20bolognese', '1719338454.62252', '', '');
INSERT INTO "cached_Web" ("content_id", "url", "updated_at", "cache", "html_website") VALUES ('AD356BEC-5C3A-46FD-B70E-0F521E4E0E31', 'https://en.wikipedia.org/wiki/Holy_trinity_(cooking)', '1719338454.63073', '', '');
INSERT INTO "cached_Web" ("content_id", "url", "updated_at", "cache", "html_website") VALUES ('AF32C11F-BBC4-47AB-8A31-B25D64659636', 'https://www.alisoneroman.com/recipes/very-crunchy-salad-feat-fennel-apples-and-pecans', '1719338454.60991', '', '');
INSERT INTO "cached_Web" ("content_id", "url", "updated_at", "cache", "html_website") VALUES ('B31464A1-E987-41A7-89A6-61205FD4E1BD', 'https://www.abeautifulplate.com/marcella-hazan-bolognese/', '1719338454.62456', '', '');
INSERT INTO "cached_Web" ("content_id", "url", "updated_at", "cache", "html_website") VALUES ('B86FE905-F89B-4FC5-91F9-34FA821F1341', 'https://www.thespruceeats.com/roasted-bok-choy-4690759', '1715361873.00429', '', '');
INSERT INTO "cached_Web" ("content_id", "url", "updated_at", "cache", "html_website") VALUES ('B8B5B87D-3779-4616-877A-933A89082D2E', 'https://www.alisoneroman.com/recipes/brothy-chickpeas-with-calabrian-chili', '1719338454.60905', '', '');
INSERT INTO "cached_Web" ("content_id", "url", "updated_at", "cache", "html_website") VALUES ('BC932DC6-C8A9-4876-A5FC-95B52D89E58B', 'https://www.google.com/search?q=mirepoix+variations&sca_esv=a334b21506059727&sxsrf=ADLYWIL2qrNYtjMTRFM-ZgDfGy6BhEJ_oQ%3A1717321965199&ei=7UBcZqPXC5KL7NYPnbuagAo&ved=0ahUKEwjjgc3t0ryGAxWSBdsEHZ2dBqAQ4dUDCBA&uact=5&oq=mirepoix+variations&gs_lp=Egxnd3Mtd2l6LXNlcnAiE21pcmVwb2l4IHZhcmlhdGlvbnMyBRAAGIAEMgsQABiABBiGAxiKBTILEAAYgAQYhgMYigUyCxAAGIAEGIYDGIoFMgsQABiABBiGAxiKBTIIEAAYgAQYogQyCBAAGIAEGKIEMggQABiABBiiBDIIEAAYgAQYogQyCBAAGIAEGKIESKorUKYHWJUqcAd4AZABAJgBjQGgAcwSqgEEMy4xOLgBA8gBAPgBAZgCHKAC3hOoAhDCAgoQABiwAxjWBBhHwgIEECMYJ8ICCxAuGIAEGJECGIoFwgILEAAYgAQYkQIYigXCAgoQABiABBhDGIoFwgILEC4YgAQY0QMYxwHCAg4QLhiABBjHARiOBRivAcICBRAuGIAEwgIIEC4YgAQY1ALCAh0QLhiABBjHARiOBRivARiXBRjcBBjeBBjgBNgBAcICChAAGIAEGBQYhwLCAg0QABiABBhDGMkDGIoFwgIOEC4YgAQYxwEYmAUYrwHCAgcQIxgnGOoCwgIUEAAYgAQY4wQYtAIY6QQY6gLYAQLCAgoQIxiABBgnGIoFwgIKEC4YgAQYQxiKBcICCBAAGBYYHhgPwgIGEAAYFhgemAMHiAYBkAYIugYGCAEQARgUugYGCAIQARgBkgcEOC4yMKAHqPoB&sclient=gws-wiz-serp', '1719338454.63197', '', '');
INSERT INTO "cached_Web" ("content_id", "url", "updated_at", "cache", "html_website") VALUES ('C0EC3AF0-01BD-4509-A8D9-FC4A7A0CBD2C', 'https://en.wikipedia.org/wiki/Epis', '1719338454.63008', '', '');
INSERT INTO "cached_Web" ("content_id", "url", "updated_at", "cache", "html_website") VALUES ('C11E649A-CBE3-45DB-B627-DAFC260F67C3', 'https://www.recipetineats.com/spaghetti-bolognese/', '1719338454.62588', '', '');
INSERT INTO "cached_Web" ("content_id", "url", "updated_at", "cache", "html_website") VALUES ('C1B014B6-4CE6-4D84-88FC-03CE52A1405F', 'https://medium.com/@drspoulsen/a-solution-to-the-onion-problem-of-j-kenji-l%C3%B3pez-alt-c3c4ab22e67c', '1719338454.6141', '', '');
INSERT INTO "cached_Web" ("content_id", "url", "updated_at", "cache", "html_website") VALUES ('C5570FCB-55A6-48B0-B707-75F88F1AE897', 'https://www.chefkoch.de/rezepte/772011180069862/Die-echte-Sauce-Bolognese.html', '1719338454.62658', '', '');
INSERT INTO "cached_Web" ("content_id", "url", "updated_at", "cache", "html_website") VALUES ('CDC67AE9-E637-4035-971F-374498AAAE3B', 'https://www.bbcgoodfood.com/recipes/collection/halloumi-salad-recipes', '1719338454.61887', '', '');
INSERT INTO "cached_Web" ("content_id", "url", "updated_at", "cache", "html_website") VALUES ('D1EDF87B-1D23-41A9-B0E3-5C0FE48AD4EF', 'https://www.davidlebovitz.com/marcella-hazans-bolognese-sauce-recipe-italian-beef-tomato/', '1719338454.62321', '', '');
INSERT INTO "cached_Web" ("content_id", "url", "updated_at", "cache", "html_website") VALUES ('DB5074A7-3B0E-4C4C-89CF-C1A963EDF5AC', 'https://www.google.com/search?sca_esv=0a31b4c8707f31fc&sxsrf=ADLYWIIzbr9zX_bH39yDp5bsAUKYXHV2LQ:1718648663861&q=how+to+cut+an+onion+kenji&udm=2&fbs=AEQNm0DrEPo0FB6LsSUQs7QZBvL3ayP6SZA-lOOB31zyTiCs1j6jSwqoTNNwl_MZUpnJvRfvov3LfS8PdD5uRoSf0fJtFhBEqXhlTGhZdUJC-BcWLafAPa6kTzgX9Mmd1lTS_xPPYF6525SuVkVgsDzjZTcqGLqoVzvyZROBbepT52R7f6_Oxpk&sa=X&ved=2ahUKEwjsk-mYoeOGAxXkW_EDHaABD6cQtKgLegQICxAB&biw=1240&bih=686&dpr=2#vhid=FlB7uRtfSJw_KM&vssid=mosaic', '1719338454.61329', '', '');
INSERT INTO "cached_Web" ("content_id", "url", "updated_at", "cache", "html_website") VALUES ('E4B76C73-9CD8-41D1-9B0A-92E16A198FE3', 'https://www.alisoneroman.com/', '1719338454.60801', '', '');
INSERT INTO "cached_Web" ("content_id", "url", "updated_at", "cache", "html_website") VALUES ('E4B7CEFB-EEAC-4AF9-82AF-3DED94331656', 'https://www.foodandwine.com/recipes/pasta-bolognese', '1719338454.62522', '', '');
INSERT INTO "cached_Web" ("content_id", "url", "updated_at", "cache", "html_website") VALUES ('F35FC52D-2673-4899-9E30-8712FE2C97B6', 'https://www.youtube.com/watch?v=UE_P1b56k_s', '1719338454.62792', '', '');
INSERT INTO "cached_Web" ("content_id", "url", "updated_at", "cache", "html_website") VALUES ('FC067D67-CCA7-4980-9B3E-E011778A19D2', 'https://www.alisoneroman.com/recipes/spicy-chicken-piccata', '1719338454.6125', '', '');
"""
	
	let doc_table = """
INSERT INTO "document" ("id", "name", "owner", "shared", "created_at", "updated_at", "updated_by", "document") VALUES ('4D90F0F2-064D-42B8-9A16-B9A613A2A162', 'Cooking', '', '0', '1719338454.59929', '1719338454.59929', '', '{
  "type" : "document",
  "data" : {
	"id" : "4D90F0F2-064D-42B8-9A16-B9A613A2A162",
	"children" : [
	  {
		"type" : "contentFrame",
		"data" : {
		  "width" : {
			"px" : 1156
		  },
		  "height" : {
			"px" : 751
		  },
		  "children" : [
			{
			  "active" : true,
			  "contentType" : "web",
			  "position" : 0,
			  "contentState" : "loaded",
			  "id" : "E4B76C73-9CD8-41D1-9B0A-92E16A198FE3"
			},
			{
			  "contentState" : "loaded",
			  "id" : "B8B5B87D-3779-4616-877A-933A89082D2E",
			  "active" : false,
			  "contentType" : "web",
			  "position" : 1
			},
			{
			  "contentState" : "loaded",
			  "id" : "AF32C11F-BBC4-47AB-8A31-B25D64659636",
			  "contentType" : "web",
			  "position" : 2,
			  "active" : false
			},
			{
			  "contentState" : "loaded",
			  "contentType" : "web",
			  "position" : 3,
			  "id" : "490242B8-8AC3-445A-947F-7510B212744A",
			  "active" : false
			},
			{
			  "contentState" : "loaded",
			  "contentType" : "web",
			  "active" : false,
			  "id" : "0A33A159-FE72-42F8-A8DB-B83E79DE710A",
			  "position" : 4
			},
			{
			  "contentState" : "loaded",
			  "id" : "FC067D67-CCA7-4980-9B3E-E011778A19D2",
			  "contentType" : "web",
			  "active" : false,
			  "position" : 5
			}
		  ],
		  "position" : {
			"x" : {
			  "px" : 28
			},
			"y" : {
			  "px" : 47.5
			},
			"posInViewStack" : 9
		  },
		  "name" : "Alison Roman",
		  "previousDisplayState" : {
			"state" : "minimised",
			"expandCollapseDirection" : "leftToRight"
		  },
		  "state" : "expanded",
		  "id" : "B295A702-92E2-479F-945D-9FC6E8A22FB5"
		}
	  },
	  {
		"type" : "contentFrame",
		"data" : {
		  "state" : "minimised",
		  "position" : {
			"y" : {
			  "px" : 215.5
			},
			"x" : {
			  "px" : 1202
			},
			"posInViewStack" : 7
		  },
		  "id" : "481841D0-5027-46CE-9FAA-6A325A3066DF",
		  "children" : [
			{
			  "contentType" : "web",
			  "id" : "6E9350AF-E4CB-4F87-80D7-447314D5797D",
			  "active" : false,
			  "position" : 0,
			  "contentState" : "loaded"
			},
			{
			  "position" : 1,
			  "contentType" : "web",
			  "contentState" : "loaded",
			  "active" : false,
			  "id" : "642AE5AB-866B-4215-944F-78C25D3C223C"
			},
			{
			  "contentState" : "loaded",
			  "id" : "CDC67AE9-E637-4035-971F-374498AAAE3B",
			  "active" : false,
			  "position" : 2,
			  "contentType" : "web"
			},
			{
			  "position" : 3,
			  "contentState" : "loaded",
			  "active" : false,
			  "contentType" : "web",
			  "id" : "9E00074B-94BB-404E-8856-26A3AF13E090"
			},
			{
			  "contentState" : "loaded",
			  "contentType" : "web",
			  "id" : "11C5EE45-B783-4FD0-B86B-0931E40196EA",
			  "position" : 4,
			  "active" : false
			},
			{
			  "position" : 5,
			  "contentState" : "loaded",
			  "id" : "1956344A-40E5-4DD3-97CE-E43190A3AE96",
			  "contentType" : "web",
			  "active" : false
			}
		  ],
		  "width" : {
			"px" : 280
		  },
		  "name" : "Halloumi",
		  "height" : {
			"px" : 301
		  }
		}
	  },
	  {
		"type" : "contentFrame",
		"data" : {
		  "width" : {
			"px" : 500
		  },
		  "state" : "frameless",
		  "height" : {
			"px" : 408.5
		  },
		  "children" : [
			{
			  "id" : "E9762558-E0D7-4FAA-9BEA-405FB306E3E6",
			  "contentType" : "img",
			  "active" : true,
			  "position" : 0,
			  "contentState" : "empty"
			}
		  ],
		  "position" : {
			"y" : {
			  "px" : 862
			},
			"posInViewStack" : 4,
			"x" : {
			  "px" : 935
			}
		  }
		}
	  },
	  {
		"data" : {
		  "state" : "frameless",
		  "children" : [
			{
			  "contentType" : "img",
			  "id" : "E52F5D89-38ED-42B3-938F-4E52105C7DF7",
			  "contentState" : "empty",
			  "position" : 0,
			  "active" : true
			}
		  ],
		  "height" : {
			"px" : 333.5
		  },
		  "position" : {
			"posInViewStack" : 2,
			"x" : {
			  "px" : 138.5
			},
			"y" : {
			  "px" : 659
			}
		  },
		  "width" : {
			"px" : 500
		  }
		},
		"type" : "contentFrame"
	  },
	  {
		"data" : {
		  "state" : "minimised",
		  "height" : {
			"px" : 309
		  },
		  "id" : "F2C5E2C0-562A-46F0-B257-81BADFB51EF6",
		  "position" : {
			"posInViewStack" : 5,
			"x" : {
			  "px" : 587.5
			},
			"y" : {
			  "px" : 1022.5
			}
		  },
		  "name" : "Flavor bases",
		  "width" : {
			"px" : 263
		  },
		  "children" : [
			{
			  "contentState" : "loaded",
			  "id" : "8FE9F792-066C-4DCD-A63F-A0F060511345",
			  "position" : 0,
			  "contentType" : "web",
			  "active" : false
			},
			{
			  "contentType" : "web",
			  "active" : false,
			  "position" : 1,
			  "id" : "C0EC3AF0-01BD-4509-A8D9-FC4A7A0CBD2C",
			  "contentState" : "loaded"
			},
			{
			  "id" : "AD356BEC-5C3A-46FD-B70E-0F521E4E0E31",
			  "active" : true,
			  "position" : 2,
			  "contentType" : "web",
			  "contentState" : "loaded"
			},
			{
			  "contentState" : "loaded",
			  "contentType" : "web",
			  "id" : "48FBAF42-9B5B-4797-88F6-660A9F49820E",
			  "position" : 3,
			  "active" : false
			},
			{
			  "position" : 4,
			  "contentState" : "loaded",
			  "contentType" : "web",
			  "id" : "BC932DC6-C8A9-4876-A5FC-95B52D89E58B",
			  "active" : false
			},
			{
			  "id" : "39C04FD8-CCE4-41DD-89C5-74BE981BE9A4",
			  "active" : false,
			  "position" : 5,
			  "contentState" : "loaded",
			  "contentType" : "web"
			},
			{
			  "contentState" : "loaded",
			  "id" : "5824925C-94DB-4F9B-8094-347308394739",
			  "position" : 6,
			  "contentType" : "web",
			  "active" : false
			}
		  ]
		},
		"type" : "contentFrame"
	  },
	  {
		"data" : {
		  "name" : "Onion math",
		  "children" : [
			{
			  "id" : "DB5074A7-3B0E-4C4C-89CF-C1A963EDF5AC",
			  "contentType" : "web",
			  "position" : 0,
			  "active" : true,
			  "contentState" : "loaded"
			},
			{
			  "id" : "C1B014B6-4CE6-4D84-88FC-03CE52A1405F",
			  "active" : false,
			  "position" : 1,
			  "contentType" : "web",
			  "contentState" : "loaded"
			},
			{
			  "position" : 2,
			  "contentState" : "loaded",
			  "id" : "7391FD3B-05CA-4BEE-9735-B15C5533AD04",
			  "contentType" : "web",
			  "active" : false
			},
			{
			  "id" : "259E1F69-E675-458B-967A-2C12B75C528A",
			  "contentState" : "loaded",
			  "position" : 3,
			  "active" : false,
			  "contentType" : "web"
			},
			{
			  "contentState" : "loaded",
			  "id" : "94E207BD-8095-4714-8246-8F8E7BA9B238",
			  "active" : false,
			  "contentType" : "web",
			  "position" : 4
			}
		  ],
		  "id" : "85D301BB-B1BF-4F40-B93C-623366CCEE13",
		  "state" : "minimised",
		  "position" : {
			"y" : {
			  "px" : 827.5
			},
			"x" : {
			  "px" : 1017.5
			},
			"posInViewStack" : 3
		  },
		  "height" : {
			"px" : 231
		  },
		  "width" : {
			"px" : 263
		  }
		},
		"type" : "contentFrame"
	  },
	  {
		"type" : "contentFrame",
		"data" : {
		  "position" : {
			"y" : {
			  "px" : 610
			},
			"x" : {
			  "px" : 36.5
			},
			"posInViewStack" : 1
		  },
		  "height" : {
			"px" : 500
		  },
		  "width" : {
			"px" : 500
		  },
		  "children" : [
			{
			  "id" : "43DC5B56-124C-4368-A341-EAA9D2E33CFD",
			  "contentType" : "img",
			  "active" : true,
			  "position" : 0,
			  "contentState" : "empty"
			}
		  ],
		  "state" : "frameless"
		}
	  },
	  {
		"data" : {
		  "name" : "Bolognese",
		  "position" : {
			"posInViewStack" : 8,
			"x" : {
			  "px" : 1203.5
			},
			"y" : {
			  "px" : 129.5
			}
		  },
		  "width" : {
			"px" : 280
		  },
		  "state" : "collapsedMinimised",
		  "children" : [
			{
			  "contentState" : "loaded",
			  "position" : 0,
			  "contentType" : "web",
			  "id" : "72F6FA20-AA1B-4755-B43B-6EB7440A25BC",
			  "active" : false
			},
			{
			  "contentState" : "loaded",
			  "position" : 1,
			  "active" : false,
			  "contentType" : "web",
			  "id" : "A6D7749F-D014-4093-9C1F-0E21C317C361"
			},
			{
			  "id" : "D1EDF87B-1D23-41A9-B0E3-5C0FE48AD4EF",
			  "position" : 2,
			  "active" : false,
			  "contentState" : "loaded",
			  "contentType" : "web"
			},
			{
			  "id" : "8D44F7BE-F135-4969-9420-69CFFF83ECED",
			  "active" : false,
			  "position" : 3,
			  "contentType" : "web",
			  "contentState" : "loaded"
			},
			{
			  "id" : "B31464A1-E987-41A7-89A6-61205FD4E1BD",
			  "position" : 4,
			  "contentType" : "web",
			  "active" : false,
			  "contentState" : "loaded"
			},
			{
			  "contentState" : "loaded",
			  "id" : "E4B7CEFB-EEAC-4AF9-82AF-3DED94331656",
			  "active" : false,
			  "contentType" : "web",
			  "position" : 5
			},
			{
			  "contentState" : "loaded",
			  "contentType" : "web",
			  "id" : "C11E649A-CBE3-45DB-B627-DAFC260F67C3",
			  "position" : 6,
			  "active" : false
			},
			{
			  "id" : "C5570FCB-55A6-48B0-B707-75F88F1AE897",
			  "active" : false,
			  "contentType" : "web",
			  "contentState" : "loaded",
			  "position" : 7
			},
			{
			  "position" : 8,
			  "contentState" : "loaded",
			  "id" : "388B4C71-A510-4466-94C1-D5795361967C",
			  "contentType" : "web",
			  "active" : false
			},
			{
			  "contentState" : "loaded",
			  "id" : "F35FC52D-2673-4899-9E30-8712FE2C97B6",
			  "position" : 9,
			  "contentType" : "web",
			  "active" : false
			},
			{
			  "contentState" : "loaded",
			  "position" : 10,
			  "contentType" : "web",
			  "active" : false,
			  "id" : "3D3F9ACE-543D-449B-8772-86948BBAC9AC"
			}
		  ],
		  "id" : "F15A5026-BD8A-4CBF-8750-8DECD5387D00",
		  "height" : {
			"px" : 74
		  }
		},
		"type" : "contentFrame"
	  },
	  {
		"data" : {
		  "width" : {
			"px" : 280
		  },
		  "name" : "Historical Food",
		  "id" : "AC8DFF11-19E7-4588-B2A5-5519EAB6A477",
		  "state" : "collapsedMinimised",
		  "height" : {
			"px" : 74
		  },
		  "children" : [
			{
			  "position" : 0,
			  "contentState" : "loaded",
			  "id" : "1121EC8E-1CE0-4E96-B831-5D11E0F57E32",
			  "active" : false,
			  "contentType" : "web"
			},
			{
			  "contentState" : "loaded",
			  "contentType" : "web",
			  "id" : "8C6DCB17-F26F-4A02-9860-306D6B9B3231",
			  "active" : false,
			  "position" : 1
			},
			{
			  "contentState" : "loaded",
			  "id" : "36B60973-8060-4C82-AD88-C1674EB9BAEA",
			  "contentType" : "web",
			  "position" : 2,
			  "active" : false
			},
			{
			  "position" : 3,
			  "id" : "8700ED25-C51D-4C4D-A1CA-72CEA23D27FF",
			  "contentType" : "web",
			  "contentState" : "loaded",
			  "active" : false
			},
			{
			  "active" : false,
			  "position" : 4,
			  "contentState" : "loaded",
			  "id" : "17AC6C87-BD2F-483E-8932-2B91182108E2",
			  "contentType" : "web"
			},
			{
			  "contentType" : "web",
			  "position" : 5,
			  "contentState" : "loaded",
			  "active" : false,
			  "id" : "55C16471-F3C0-4096-94AF-5CB06B07704B"
			}
		  ],
		  "position" : {
			"posInViewStack" : 6,
			"x" : {
			  "px" : 1201
			},
			"y" : {
			  "px" : 45
			}
		  }
		},
		"type" : "contentFrame"
	  }
	],
	"height" : {
	  "px" : 2368
	},
	"viewPosition" : {
	  "px" : 0
	},
	"width" : {
	  "px" : 1512
	}
  }
}');
"""
}
