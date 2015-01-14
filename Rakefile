desc 'Run thin server port: 4567'
task :start do
  sh 'thin -p 4567 -D -R config.ru start'
end

desc 'Run specs test'
task :spec do
  sh 'rspec ./spec'
end
