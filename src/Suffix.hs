-- | This module defines variations on a function `suffix`, which does the following:
--
-- > λ:> suffix "tails"
-- > ["ails","ils","ls","s"]
--
-- > λ:> suffix "s"
-- > []
module Suffix ( suffix
              , suffixPattern
              , suffixPattern2
              , suffixList
              , suffixFunctor
              , suffixPattern3
              , suffixPatternRev
              , suffixZipper
              , suffixHylo
              ) where

import Data.Functor.Foldable

-- | This uses a hylomorphism
suffixHylo :: [a] -> [[a]]
suffixHylo = hylo algebra coalgebra . drop 1

algebra :: ListF [a] [[a]] -> [[a]]
algebra Nil         = []
algebra (Cons x xs) = x:xs

coalgebra :: [a] -> ListF [a] [a]
coalgebra []     = Nil
coalgebra (x:xs) = Cons (x:xs) xs

-- | This uses recursion schemes
suffix :: [a] -> [[a]]
suffix = para pseudoalgebra

-- | This is not technically an F-algebra in the mathematical sense
pseudoalgebra :: (Base [a]) ([a], [[a]]) -> [[a]]
pseudoalgebra Nil        = mempty
pseudoalgebra (Cons _ x) = uncurry go $ x
    where go y@(x:xs) suffixes = y:suffixes
          go _ suffixes        = suffixes

-- | This uses pattern matching, and reverses the result at the end.
suffixPattern :: [a] -> [[a]]
suffixPattern x = reverse $ curry (snd . go) x mempty
    where go ((x:xs), suffixes) = go (xs, if not $ null xs then xs:suffixes else suffixes)
          go (_, suffixes)      = ([], suffixes)

-- | This uses pattern matching, and ignore the fact that everything is backwards. 
-- It's included in the benchmark to show the problem is pattern matching itself.
suffixPatternRev :: [a] -> [[a]]
suffixPatternRev x = curry (snd . go) x mempty
    where go ((x:xs), suffixes) = go (xs, if not $ null xs then xs:suffixes else suffixes)
          go (_, suffixes)      = ([], suffixes)

-- | This uses pattern matching, and appends the lists to build it in the right order
suffixPattern2 :: [a] -> [[a]]
suffixPattern2 x = curry (snd . go) x mempty
    where go ((x:xs), suffixes) = go (xs, if not $ null xs then suffixes ++ [xs] else suffixes)
          go (_, suffixes)      = ([], suffixes)

-- | This uses pattern matching wihtout ugliness, but it's partial. It's benchmarked
-- to show the problem isn't if-branching.
suffixPattern3 :: [a] -> [[a]]
suffixPattern3 x = curry (snd . go) x mempty
    where go ((x:[]), suffixes) = ([], suffixes)
          go ((x:xs), suffixes) = go (xs, suffixes ++ [xs])

-- | This uses list comprehensions
suffixList :: [a] -> [[a]]
suffixList x = [ drop n x | n <- [1..(length x - 1)]]

-- | This uses functoriality
suffixFunctor :: [a] -> [[a]]
suffixFunctor x = fmap (flip drop x) [1..(length x -1)]

-- | This uses a zipper
suffixZipper :: [a] -> [[a]]
suffixZipper y@[x]    = mempty
suffixZipper y@(x:xs) = zipWith drop [1..] $ map (const y) (init y)
suffixZipper _        = mempty
