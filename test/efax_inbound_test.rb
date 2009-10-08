require File.dirname(__FILE__) + '/test_helper'
require File.dirname(__FILE__) + '/../lib/efax/inbound'
require 'efax/helpers/inbound_helpers'

module EFaxInboundTest
  class InboundPostRequestTest < Test::Unit::TestCase
    include EFax::Helpers::InboundHelpers

    def test_receive_by_params
      EFax::InboundPostRequest.expects(:receive_by_xml).with(xml).returns(response = mock)
      assert_equal(EFax::InboundPostRequest.receive_by_params({:xml => xml}), response)
    end
    
    def test_receive_by_xml
      response = efax_inbound_post

      assert_equal file_contents,  response.encoded_file_contents
      assert_equal :pdf,           response.file_type
      assert_equal '098-765-4321', response.sender_fax_number
      assert_equal '098-765-4321', response.ani
      assert_equal '1234567890',   response.account_id
      assert_equal '48794686',     response.fax_name
      assert_equal '1234567890',   response.csid
      assert_equal 0,              response.status
      assert_equal 59985697,       response.mcfid
      assert_equal 1,              response.page_count
      assert_equal 'New Inbound',  response.request_type
      assert_not_nil response.file_contents
      assert_not_nil response.file
      assert_respond_to response.file, :read
      assert_equal response.file_contents, response.file.read
      
      # According to docs these will always be "Pacific Time Zone" (sometimes -8, sometimes -7 -- using -8)
      assert_equal Time.utc(2009,9,29,23,56,35), response.date_received
      assert_equal Time.utc(2009,9,30, 0, 1,11), response.request_date
    end

    
    def xml
      %Q{
        <?xml version="1.0"?>
        <InboundPostRequest>
          <AccessControl>
            <UserName></UserName>
            <Password></Password>
          </AccessControl>
          <RequestControl>
            <RequestDate>09/29/2009 16:01:11</RequestDate>
            <RequestType>New Inbound</RequestType>
          </RequestControl>
          <FaxControl>
            <AccountID>1234567890</AccountID>
            <DateReceived>09/29/2009 15:56:35</DateReceived>
            <FaxName>48794686</FaxName>
            <FileType>pdf</FileType>
            <PageCount>1</PageCount>
            <CSID>1234567890</CSID>
            <ANI>098-765-4321</ANI>
            <Status>0</Status>
            <MCFID>59985697</MCFID>
            <FileContents>#{file_contents}</FileContents>
          </FaxControl>
        </InboundPostRequest>
      }
    end
    
    def file_contents
     %Q| JVBERi0xLjYKJeTjz9IKMSAwIG9iagpbL1BERi9JbWFnZUIvSW1hZ2VDL0ltYWdlSS9UZXh0XQplbmRvYmoKMyAwIG9iago8PC9TdWJ0eXBlL0ltYWdlCi9XaWR0aCAxNzI4Ci9IZWlnaHQgMjIwMAovQml0c1BlckNvbXBvbmVudCAxCi9Db2xvclNwYWNlL0RldmljZUdyYXkKL0ZpbHRlci9DQ0lUVEZheERlY29kZQovRGVjb2RlUGFybXM8PC9LIC0xL0VuZE9mQmxvY2sgZmFsc2U+PgovTGVuZ3RoIDQgMCBSCj4+CnN0cmVhbQrI4OaClTMigMHY4pFc7GxDtWKRdEDDBJSJJf///4ZvDKGHms1zvGoMEdjbTDNMMH//////w25DGaGRx5s/zwU5kciORwyOTkMedQuSA5zI5EcjMZDCunhswMuM+FygjMUuKJDCf/////////////pYRcBhieA9Aq3CL8NidxO7YlQHhFwGaAgRfh6NNsTuJ3YRcBhF+HoER7wdGhhF+GZhARdgwwgwj4oRfB//////////////////xWIbYQb0hxQQbppthBvENkiQQb8aabENoIN6TfsUKCDYRd0EG3okNBBv///////////////mmHnQT9Lj/286CcZUBjZC/8+JHpN4ShRoJ0m20nx//////////////8N4Rd/iHzV//CLvzbESXf4Rd5lFC4hVMnX7aX///////////////hBfzWH5O/9LCC/J3lGH/CC8nejUcwjk7vbSYrye////////////////8JJ0EyP/hvYYQX8MJJ0EyP2YbDCC7C/0EyPsMIJNJvTYYQTDCsMJNJsMJf////////////////+EIRmCMTuKCDCDCDCDBAwxCTTThEcicEYncUGIQYhAgbEJNNNidxQYhGgIgwmEDBAwxCDEodgxBNEMEDEL/////////////xERERERERURERERERERERERERER9B+P/////////5kFhTvgpWI6xGwIOzOJEZBDO0R2SRW7ByGAQrP+QRL/uwv/hV/zTc1H+Sm/m3r/hvfx///t7////ckIp0al2UI6rzaJNZqRQinR1RFEULyNrJCNaIhGtEQskIlazaIkiMRJFkhETWSEa0U6NS+ZilAh6CD8+KCIvA8EDPxyBA8nggzgpQICIvmmazDhnBfO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3r8LhBhB6DCDx71S0Di9BhB/rr3/6v/6/pur3/3/9r6va//a+v6694/vSS+P/j1TiNLe6/uI/W3tpf+k9fXt14pOl9aX19jTaT2PTfXf/+3tpdhggwUlf8MF3aX+iV0Sh31rpc/OSveaqlpf///+l+l////wf/B//rtr+lpfyUfpvSS+Si/8nPQenkoI4pL+li9NyUEcfxx////8f////+wf+wf/6f1/HH5DEp/8f+ntf9IUm6afSfpLJwn00////////////YP/YP/9Fu//////Vf96///1Su1iDBf//NUZX////mr/////lA/8nH//T7a/zVG1///Vf////9JaM/1/////////////g/+D//rf1//j///+xX///hL/0Sv//227////b9szv/+//PJ/84n//Sb//bb//9JL////9JJ/rr//+ZvM26/7aX/5m/9tJv/df8L2k2kF+0v0m91/zN5m2//0jh//1a+cNsEVDS/wlHGdT/S//dXV//f2v3X2lfa/3/9/33+v9fFf3V1a/+ukl/vH/YW1/SRBfF+uv/21bVhhfsjrbCW2F9tfbVsJNr+wwtgin+2lYSbCTaVkdWl+rf8hjS2ratr8HBxX8H/T/sbFf+7XHFf/YpimJx/x7FcfsV7FMUx/sTj4/2OKYpjjiv0m9/2KYpj93rVX/eRR/7tfr/vX/2Ewg1++1hkn+wvaaZGP/DW/7CmdNMJ5h1+k/X7CYTIx/u8mOuqf/DX+GEGF/X+GSHyY6/iIiOIiIiIiIiIiIiIjiIiOIiIiIiIiIiIiIiIjiPiIikIiIiIiOIiIjiIj/0ktLlcysrqV/9f0tL0klS8GCwYL4jQ9iExCxEYYQYXER///////8yCmdmUdI6R2BBSNskRyO9YhhSF3/g/+D//d/w//zTd/y5/+OG/H2//t3+/yDRE0SaIxHVeSaNSKdHVblCvIhFWinRqX5DWSEU6KdGtHVcpxT0aR4UjBD8CBggfnmbgRFoRTgwRFSc5BByx+cjMUpxD0CBggf5oLmYpQIegQMnFBEVqJ9B9JhOLCHpaaaafce36YTiwh+g9MJxaafRd9UXjm5yeObOlo2NGxovGjY94Ij/fou3Nzk8c2dJF30Xjm5yeNF40bH0g23pNpPTpPpdPTpN0/wh39J0np0nikg3pNpPTpN0/q9Kv/30va2q9r/b+m//eqvr/69rpO/tj1pel2Njt2P13+I9aXDSf2x69ux/3pa/8VwcGlwf+/pL/y6P9LX0uD/6UZqCf97BsHGwf+3+TAT/2/4zMJ8bB/2/Bf+9g2D2D1+/wX/3/wX9g//Uysln/lvycZOOYG/9/0Sz///NWSz8wN/9eC/+m8HB8H69v+C///KL4L/B/7e2l//ecTnE7ZqT6/Htmcl///7aX7ZqT9tLrM3/t++FwvmbC/Xv//t+raX5m//M2F/ex3Vr9rt9991fhfftK1+10r7SurX7q/IYxhLbVwvtr3tpNpNq2keor/bVwvtrG2EmwrauF9tW0uxVMVH7HvsbGxTH177FR+x0xUUxUfsUx9p2EyLD9kY/vYTCYTC4L32mRYfsjHwmg0wmRYfsJhREREREREREREOIiIiIiIiIiIiIiNfS1H/5kFR3Gf+RiM0q8KFqv////qvOLyQqolCNaOqKEUiNS4IGEDCBl4EDM7zcXI2M0FJxT0EGcEIwU0FPxcjY8X8Q9Vi1QacYTTQcWuTxhggwUnnqpOxKtou6LtwRH5uaLtou8nYlW9P9Nj9NOkG0nhCk6TpBumn////V03/TdX/r+m1Wq0nxofFJ6r//1X/papf//////JAT///+q//4L///////RLP///+q//4L//////7ZnaW2Z3//+0lX9tL//bS///1X99pdraV//7I6sEU7CR6/9sJNruFPTathL/8ccV/+xTFcexTFf/d5nWq/tNbIsPaa/iIjiIiIiIiIiIiI///x/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////+ACACCmVuZHN0cmVhbQplbmRvYmoKNCAwIG9iago0MTY1CmVuZG9iago2IDAgb2JqCjw8L0xlbmd0aCA3IDAgUgovRmlsdGVyL0ZsYXRlRGVjb2RlCj4+CnN0cmVhbQp4nCvkMjOw1LOwMDJRMABCCwMLPUMzY2MwJzmXS9/TQMElnyuQCwCiLAf0CmVuZHN0cmVhbQplbmRvYmoKNyAwIG9iago0MwplbmRvYmoKOCAwIG9iago8PC9Qcm9jU2V0IDEgMCBSCi9YT2JqZWN0PDwvSTAgMyAwIFIKPj4KPj4KZW5kb2JqCjkgMCBvYmoKPDwvQ3JlYXRpb25EYXRlIChEOjIwMDkwOTI5MTYwOTI0LTA3JzAwJykKL1Byb2R1Y2VyIChQREZsaWIgNy4wLjMgXChKREsgMS42L1dpbjMyXCkpCj4+CmVuZG9iago1IDAgb2JqCjw8L1R5cGUvUGFnZQovUGFyZW50IDIgMCBSCi9Db250ZW50cyA2IDAgUgovUmVzb3VyY2VzIDggMCBSCi9NZWRpYUJveFswIDAgNjA5Ljg4MjQgODA4LjE2MzNdCj4+CmVuZG9iagoyIDAgb2JqCjw8L1R5cGUvUGFnZXMKL0NvdW50IDEKL0tpZHNbIDUgMCBSXT4+CmVuZG9iagoxMCAwIG9iago8PC9UeXBlL0NhdGFsb2cKL1BhZ2VzIDIgMCBSCj4+CmVuZG9iagp4cmVmCjAgMTEKMDAwMDAwMDAwMCA2NTUzNSBmIAowMDAwMDAwMDE1IDAwMDAwIG4gCjAwMDAwMDQ4NTAgMDAwMDAgbiAKMDAwMDAwMDA2MyAwMDAwMCBuIAowMDAwMDA0NDI1IDAwMDAwIG4gCjAwMDAwMDQ3MzkgMDAwMDAgbiAKMDAwMDAwNDQ0NSAwMDAwMCBuIAowMDAwMDA0NTYwIDAwMDAwIG4gCjAwMDAwMDQ1NzggMDAwMDAgbiAKMDAwMDAwNDYzNiAwMDAwMCBuIAowMDAwMDA0OTA0IDAwMDAwIG4gCnRyYWlsZXIKPDwvU2l6ZSAxMQovUm9vdCAxMCAwIFIKL0luZm8gOSAwIFIKL0lEWzw1NUMzQUY5Rjk3QzNBQjMwN0I2OTIzNTcxM0Q1RUVFND48NTVDM0FGOUY5N0MzQUIzMDdCNjkyMzU3MTNENUVFRTQ+XQo+PgpzdGFydHhyZWYKNDk1MgolJUVPRgo=|
    end
  end
end

