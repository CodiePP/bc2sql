
# db schema

[](DBschema1.png)

[Postgres SQL schema](bc2sql001.sql)

# data gathering

## block -> transactions

./block_txs.sh <block hash>

## transaction -> inputs, outputs

./txs_summary.sh <trx hash>

## pages of 10 blocks

### get the number of pages in the blockchain

./npages.sh

### get 10 blocks for a page

./get_page.sh <page #>


# queries

`<tbd>`

