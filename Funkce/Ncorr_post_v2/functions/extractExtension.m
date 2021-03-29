function nameWithoutExtension = extractExtension(fileName)

for index = length(fileName):-1:1
  if (fileName(index) == '.')
    break;
  end
end

nameWithoutExtension = fileName(1:index-1);

end