require 'sinatra'

require 'kramdown'

require 'dependo'
require 'r509/ocsp/responder/server'
require 'r509/validity/crl'

crl_paths = [File.expand_path('../ca/revoked.crl', __FILE__)]

reload_interval = '5s' #yolo
Dependo::Registry[:validity_checker] = R509::Validity::CRL::Checker.new(
                                                                        crl_paths, 
                                                                        reload_interval
                                                                        )
Dependo::Registry[:log] = Logger.new STDERR

Dir.chdir File.join(File.dirname(__FILE__), 'ca') do
  R509::OCSP::Responder::OCSPConfig.load_config
end

set :public_folder, File.join(File.dirname(__FILE__), 'ca')

helpers do
  def ocsp_server
    @ocsp_server ||= R509::OCSP::Responder::Server
  end
end

get '/' do
  haml :index
end

get '/ocsp/*' do
  ocsp_server.call env
end

run Sinatra::Application