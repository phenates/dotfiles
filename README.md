# dotfiles
My dotfiles managament with [chezmoi](https://www.chezmoi.io)

> [!TIP]
> Install command:
> ```shell
> sh -c "$(wget -qO- https://raw.githubusercontent.com/phenates/dotfiles/master/install.sh)"
> ```

## Tips
### Write Access
1. Generate an SSH key if there isn't one yet.
    ```
    ssh-keygen -t ed25519
    cat ~/.ssh/id_ed25519.pub | wlcopy
    ```
2. On Github go to [Settings > SSH and GPG keys](https://github.com/settings/keys) and add it there.
   
3. Change the repo's `origin` remote to use SSH:
    ```
    git remote set-url origin git@github.com:juliekoubova/dotfiles.git
    ```
