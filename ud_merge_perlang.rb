INPATH = "C:\\Sasha\\D\\DGU\\ud-treebanks-v2.6"
OUTPATH = "C:\\Sasha\\D\\DGU\\UD26langs"

filelist = Dir.entries(INPATH).reject{|a| a == "." or a == ".." or a[-3..-1]=="txt" or a[-3..-1]==".rb"}
languagefiles = {}
filelist.each do |directory|
  STDERR.puts directory[3..-1]
  language = directory[3..-1].split("-")[0]
  STDERR.puts language
  #conllu = Dir.entries(directory).reject{|a| a == "." or a == ".." or a[-6..-1]!="conllu"}
  if languagefiles[language].nil?
    languagefiles[language] = File.new("#{OUTPATH}\\#{language}.conllu","w:utf-8")
  #else
  #  
  end
  conllufile = File.open("#{INPATH}\\#{directory}\\#{directory[3..-1]}.conllu","r:utf-8")
  #conllu.each do |file|
  #  inf = File.open("#{directory}/#{file}","r:utf-8")
  conllufile.each_line do |line|
	languagefiles[language].puts line
  end  
	
  conllufile.close
end