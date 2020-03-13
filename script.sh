echo 'begining Embulk script'

# if you need to check what plugins are installed :
# embulk gem list

embulk preview configuration.yml
embulk run     configuration.yml

echo 'Finished embulk'
