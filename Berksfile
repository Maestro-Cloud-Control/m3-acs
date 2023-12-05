source 'https://supermarket.chef.io'
metadata
solver :ruby, :required
def dependencies(path)
  berks = "#{path}/Berksfile"
  instance_eval(File.read(berks)) if File.exist?(berks)
end
Dir.glob('./cookbooks/*').each do |path|
  dependencies path
  cookbook File.basename(path), path: path
end

