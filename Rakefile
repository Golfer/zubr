task :start do
  sh 'thin -p 4567 -D -R config.ru start'
end

desc 'Run specs test'
task :test do
  sh 'rspec ./spec'
end
