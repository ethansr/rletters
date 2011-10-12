# -*- encoding : utf-8 -*-
require 'test_helper'

class OpenURLTest < ActiveSupport::TestCase
  test "should create good OpenURL params" do
    stub_solr_response(:precise_one_doc)
    doc = Document.find('00972c5123877961056b21aea4177d0dc69c7318')
    
    str = doc.to_openurl_params
    assert_equal "ctx_ver=Z39.88-2004&rft_val_fmt=info%3Aofi%2Ffmt%3Akev%3A" \
      "mtx%3Ajournal&rft.genre=article&" \
      "rft_id=info:doi%2F10.1111%2Fj.1439-0310.2008.01576.x" \
      "&rft.atitle=How+Reliable+are+the+Methods+for+" \
      "Estimating+Repertoire+Size%3F" \
      "&rft.title=Ethology&rft.date=2008&rft.volume=114" \
      "&rft.spage=1227&rft.epage=1238&rft.aufirst=Carlos+A." \
      "&rft.aulast=Botero&rft.au=Andrew+E.+Mudge" \
      "&rft.au=Amanda+M.+Koltz&rft.au=Wesley+M.+Hochachka" \
      "&rft.au=Sandra+L.+Vehrencamp", str
  end
end
