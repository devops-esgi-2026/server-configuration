 
# Une fois déployé sur votre serveur :
chmod +x incident-scheduler
sudo mv incident-scheduler /usr/local/bin/incident-scheduler

# Créer le fichier de log (contient le code du dernier incident levé, si vous bloquez trop longtemps, je peux vous dire ce qu'il veut dire
sudo touch /var/log/incident-generator.log
sudo chmod 777 /var/log/incident-generator.log # pas très prod ready, mais plus simple pour lire rapidement pas galérer


# Vous pouvez l'exécuter deux ou trois fois pour voir s'il casse des choses (il ne va pas obligatoirement le faire)


# Si vous être confiants, vous pouvez jouer à la roulette russe toutes les 15 minutes :

echo "*/15 * * * * root /usr/local/bin/incident-scheduler" | sudo tee /etc/cron.d/incident-scheduler
sudo chmod 644 /etc/cron.d/incident-scheduler

---
dans grafana
kube api down
kubelet
> service K3s stoppé , il faut le redémmarer