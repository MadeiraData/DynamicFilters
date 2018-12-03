CREATE TABLE [dbo].[FilterPredicates] (
    [PredicateID]       INT            NOT NULL,
    [IsMultiValue]      BIT            NOT NULL,
    [PredicateName]     VARCHAR (50)   NOT NULL,
    [PredicateTemplate] VARCHAR (4000) NOT NULL,
    PRIMARY KEY CLUSTERED ([PredicateID] ASC)
);

