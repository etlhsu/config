# Zsh Tips

```shell

# Choose from a list
select out in a b c d; do
  echo "char: $out option: $REPLY"
  break # If single shot
done
```

## Random Commands
* `^N` - accept suggestion 
* `\` - decline suggestion
* `zle -la` - list all zsh widgets
