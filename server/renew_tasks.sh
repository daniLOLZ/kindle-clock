echo `date` "starting job" >> /home/dani/test/renew_log.log

# Update code
export PATH="$HOME/.local/bin:$PATH"
eval `ssh-agent -s` 
ssh-add ~/.ssh/daniLOLZ_GitHub 
cd ~/code/kindle-clock && git checkout feat/tasknotes && git pull

# Extract
cd ~/code/kindle-clock && server/extract_tasknotes.sh "/DATA/Documents/Obsidian Vault/TaskNotes/Tasks/" ~/logs/tasks.json 
echo `date` "finished job" >> /home/dani/test/renew_log.log
