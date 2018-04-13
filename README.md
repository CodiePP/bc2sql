
# db schema

![](DBschema1.png)

[Postgres SQL schema](bc2sql001.sql)

# data gathering

## block -> transactions

```sh
./block_txs.sh <block hash>
```

## transaction -> inputs, outputs

```sh
./txs_summary.sh <trx hash>
```

## pages of 10 blocks

### get the number of pages in the blockchain

```sh
./npages.sh
```

### get 10 blocks for a page

```sh
./get_page.sh <page #>
```

### a whole range

```sh
. colors.sh; for P in `seq 85002 86999`; do prtBlue "${P}  "; ./get_page.sh ${P} | psql -q -d bc2sql001 --; done
```

# queries

`<tbd>`

