
# db schema

![](DBschema1.png)

[Postgres SQL schema](bc2sql001.sql)

table [magnitude](table_magnitude.sql) is used in some queries.

a user `bc2sql` needs to be created. this user has readonly access. the Haskell programs will connect using this role to query the database.

``` sql
CREATE ROLE bc2sql LOGIN
  NOSUPERUSER INHERIT NOCREATEDB NOCREATEROLE NOREPLICATION;
```

# compilation

after adapting `Explorer/Config.hs` to your needs you may want to compile
the program to load data from the explorer into your local database using
these two steps:

1. enter a Nix shell:

```
nix-shell
```
this will bring the required packages (see `shell.nix`) into the environment

2. compile and install the binaries in directory `bin`:

```
stack install
```

now `bin/` should contain the binaries `npages` and `get-pages`
which are used by the script `catch_up.sh`.


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

## find transactions with input and output addresses the same
```sql
select hash, issued, suminput, sumoutput from transaction
JOIN
(select t1.trxid from trxaddrinputrel t1, trxaddroutputrel t2
where 
      t2.addrid = t1.addrid
and   t1.trxid = t2.trxid) AS q2
ON transaction.trxid=q2.trxid
```

# data validation

Aside from `foreign keys` setup in the db schema, we can validate input data at the block and transaction level:

## blocks per page: 10

we know that each page reports on 10 blocks.

```
-- verify page has 10 blocks
-- outputs the pagenr which do not 
SELECT COUNT(*) as n_blocks, pagenr
FROM block
WHERE pagenr > 0
GROUP BY pagenr
HAVING COUNT(*) != 10;
```
this query can be run from the file [](verify_pages.hs)

## number of transactions matches count in blocks

```
-- count number of transactions per block
-- and compare to field 'n_tx'
SELECT * FROM
  (SELECT blockid, n_tx FROM block) AS t1
JOIN 
  (SELECT COUNT(*) as n_trxs, blockid
   FROM transaction
   GROUP BY transaction.blockid) AS t2
ON
  t1.blockid = t2.blockid
  WHERE t1.n_tx != t2.n_trxs;
```

## sum of transaction details equal to reported sums

<tbd>

# Haskell implementation

## get page of ten blocks

```
./show_page.hs 3333
```

reference JSON:

{
  "Right": [
    95446,
    [
      {
        "cbeEpoch": 1,
        "cbeSlot": 11748,
        "cbeBlkHash": "dc220b4e4384f5b8d21f78a7ae666e59dcb7fd4d6794a1411d3e016d0d9233d3",
        "cbeTimeIssued": 1506870051,
        "cbeTxNum": 1,
        "cbeTotalSent": {
          "getCoin": "1923474000000"
        },
        "cbeSize": 909,
        "cbeBlockLead": "1deb82908402c7ee3efeb16f369d97fba316ee621d09b32b8969e54b",
        "cbeFees": {
          "getCoin": "0"
        }
      },
      {
        "cbeEpoch": 1,
        "cbeSlot": 11747,
        "cbeBlkHash": "119e04575a7a2281c4bc7ab319524ef09b9e3c2d2f4d4cdd3b7fbeafffce369c",
        "cbeTimeIssued": 1506870031,
        "cbeTxNum": 0,
        "cbeTotalSent": {
          "getCoin": "0"
        },
        "cbeSize": 666,
        "cbeBlockLead": "43011479a595b300e0726910d0b602ffcdd20466a3b8ceeacd3fbc26",
        "cbeFees": {
          "getCoin": "0"
        }
      },
      {
        "cbeEpoch": 1,
        "cbeSlot": 11746,
        "cbeBlkHash": "ddbb6afbd7c26e7148fb0fac7e15a02fd1d85c73145a03108d3647d04b97a835",
        "cbeTimeIssued": 1506870011,
        "cbeTxNum": 1,
        "cbeTotalSent": {
          "getCoin": "1692307000000"
        },
        "cbeSize": 909,
        "cbeBlockLead": "6c9e14978b9d6629b8703f4f25e9df6ed4814b930b8403b0d45350ea",
        "cbeFees": {
          "getCoin": "0"
        }
      },
      {
        "cbeEpoch": 1,
        "cbeSlot": 11745,
        "cbeBlkHash": "180548900b02e3cedb78b550abb4a130b1af5440b5cdb8a7aab507a430831f4e",
        "cbeTimeIssued": 1506869991,
        "cbeTxNum": 1,
        "cbeTotalSent": {
          "getCoin": "649822000000"
        },
        "cbeSize": 909,
        "cbeBlockLead": "af2800c124e599d6dec188a75f8bfde397ebb778163a18240371f2d1",
        "cbeFees": {
          "getCoin": "0"
        }
      },
      {
        "cbeEpoch": 1,
        "cbeSlot": 11744,
        "cbeBlkHash": "55e1c98361afac115719eb8cbf3d55ff4823ce3d41c748e840b7aae8b3fccedc",
        "cbeTimeIssued": 1506869971,
        "cbeTxNum": 1,
        "cbeTotalSent": {
          "getCoin": "705402000000"
        },
        "cbeSize": 909,
        "cbeBlockLead": "1deb82908402c7ee3efeb16f369d97fba316ee621d09b32b8969e54b",
        "cbeFees": {
          "getCoin": "0"
        }
      },
      {
        "cbeEpoch": 1,
        "cbeSlot": 11743,
        "cbeBlkHash": "e7c29afd61db8e71c82b8f706321cf5fff762bac3b90aaffc0b41787922a7545",
        "cbeTimeIssued": 1506869951,
        "cbeTxNum": 2,
        "cbeTotalSent": {
          "getCoin": "3174733000000"
        },
        "cbeSize": 1152,
        "cbeBlockLead": "6c9e14978b9d6629b8703f4f25e9df6ed4814b930b8403b0d45350ea",
        "cbeFees": {
          "getCoin": "0"
        }
      },
      {
        "cbeEpoch": 1,
        "cbeSlot": 11742,
        "cbeBlkHash": "225c09282df5953e5d68f4df7fab50bbb5c854b6c34c684b3b38f3ee5e64cbf0",
        "cbeTimeIssued": 1506869931,
        "cbeTxNum": 0,
        "cbeTotalSent": {
          "getCoin": "0"
        },
        "cbeSize": 666,
        "cbeBlockLead": "5071d8802ddd05c59f4db907bd1749e82e6242caf6512b20a8368fcf",
        "cbeFees": {
          "getCoin": "0"
        }
      },
      {
        "cbeEpoch": 1,
        "cbeSlot": 11741,
        "cbeBlkHash": "30641bb99f50950f468dc9656c9854fc990de5dbff49c48b8c4e35beb224eb6d",
        "cbeTimeIssued": 1506869911,
        "cbeTxNum": 0,
        "cbeTotalSent": {
          "getCoin": "0"
        },
        "cbeSize": 666,
        "cbeBlockLead": "65904a89e6d0e5f881513d1736945e051b76f095eca138ee869d543d",
        "cbeFees": {
          "getCoin": "0"
        }
      },
      {
        "cbeEpoch": 1,
        "cbeSlot": 11740,
        "cbeBlkHash": "0d1404fb6e23611c9ea89d57b4c8431ac3b1d8a377c95e4c13a4d74969db1050",
        "cbeTimeIssued": 1506869891,
        "cbeTxNum": 1,
        "cbeTotalSent": {
          "getCoin": "763781000000"
        },
        "cbeSize": 909,
        "cbeBlockLead": "5071d8802ddd05c59f4db907bd1749e82e6242caf6512b20a8368fcf",
        "cbeFees": {
          "getCoin": "0"
        }
      },
      {
        "cbeEpoch": 1,
        "cbeSlot": 11739,
        "cbeBlkHash": "2c635fc4a26e1eb4307de205ec3bd1836e2f37c67185e9e8e7663fd57721b264",
        "cbeTimeIssued": 1506869871,
        "cbeTxNum": 1,
        "cbeTotalSent": {
          "getCoin": "576923000000"
        },
        "cbeSize": 909,
        "cbeBlockLead": "5411c7bf87c252609831a337a713e4859668cba7bba70a9c3ef7c398",
        "cbeFees": {
          "getCoin": "0"
        }
      }
    ]
  ]
}


## get block transactions

```
./show_block.hs 27b0471fa372485ae569a3657f6c9a0b8d6c36874f3aaa6a2c4e7147befbe2c0
```

reference JSON:

{
  "Right": [
    {
      "ctbId": "81056d7778f7201b1547f36a66a77ed3b4293fb355738aa409c8009a988c6f72",
      "ctbTimeIssued": 1523205131,
      "ctbInputs": [
        [
          "DdzFFzCqrhsyLZcKp3TtZgiigNPhieSLZqUDgL8PYzNPbAFQ4d2sdsCRkSyhEgSghNFqDKAoMDjhVz2rQwuaomweZcYgj3qiWBcRfypb",
          {
            "getCoin": "6603547326093"
          }
        ]
      ],
      "ctbOutputs": [
        [
          "DdzFFzCqrhsvTGheDEaSZVmcJfzXjSZXCPTBUELPbSimpkJvuka1AAQw5PoEcRMuiM6YKpg9HoXoGfrBzfEgYfZYbvxpx3LhLitR3ycc",
          {
            "getCoin": "6595356285743"
          }
        ],
        [
          "DdzFFzCqrht2yA3U3tBk78QnhAyQ5p9FsNb4g9rFQkKAtW1k6tNf1Z6txnSj4mQWsRs7Rr87ukrAVHjWuTbR52JJTvD6VUTnsABqCHqe",
          {
            "getCoin": "7700291000"
          }
        ],
        [
          "DdzFFzCqrht3FU4SCLWFK62MFWBPvDzSXP43KU53Ff7z4NY4JrzxEUyXvZZR4k7FhokKtNdCLiwcHNmj3hrWJ8m5aAv6hnbRAD7uczdu",
          {
            "getCoin": "490574500"
          }
        ]
      ],
      "ctbInputSum": {
        "getCoin": "6603547326093"
      },
      "ctbOutputSum": {
        "getCoin": "6603547151243"
      }
    }
  ]
}



