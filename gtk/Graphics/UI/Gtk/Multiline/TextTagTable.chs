-- -*-haskell-*-
--  GIMP Toolkit (GTK) Widget TextTagTable
--
--  Author : Duncan Coutts
--
--  Created: 4 August 2004
--
--  Version $Revision: 1.3 $ from $Date: 2005/02/25 01:11:36 $
--
--  Copyright (C) 2004-2005 Duncan Coutts
--
--  This library is free software; you can redistribute it and/or
--  modify it under the terms of the GNU Lesser General Public
--  License as published by the Free Software Foundation; either
--  version 2.1 of the License, or (at your option) any later version.
--
--  This library is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
--  Lesser General Public License for more details.
--
-- |
-- Maintainer  : gtk2hs-users@lists.sourceforge.net
-- Stability   : provisional
-- Portability : portable (depends on GHC)
--
-- Collection of tags that can be used together
--
module Graphics.UI.Gtk.Multiline.TextTagTable (
-- * Description
-- 
-- | You may wish to begin by reading the text widget conceptual overview
-- which gives an overview of all the objects and data types related to the
-- text widget and how they work together.

-- * Class Hierarchy
-- |
-- @
-- |  'GObject'
-- |   +----TextTagTable
-- @

-- * Types
  TextTagTable,
  TextTagTableClass,
  castToTextTagTable,

-- * Constructors
  textTagTableNew,

-- * Methods
  textTagTableAdd,
  textTagTableRemove,
  textTagTableLookup,
  textTagTableForeach,
  textTagTableGetSize
  ) where

import Monad	(liftM)

import System.Glib.FFI
import System.Glib.GObject	(makeNewGObject)
{#import Graphics.UI.Gtk.Types#}
{#import Graphics.UI.Gtk.Signals#}

{# context lib="gtk" prefix="gtk" #}

--------------------
-- Constructors

-- | Creates a new 'TextTagTable'. The table contains no tags by default.
--
textTagTableNew :: IO TextTagTable
textTagTableNew =
  makeNewGObject mkTextTagTable $ 
  {#call unsafe text_tag_table_new#}

--------------------
-- Methods

-- | Add a tag to the table. The tag is assigned the highest priority in the
-- table.
--
-- The tag must not be in a tag table already, and may not have the same name as
-- an already-added tag.
--
textTagTableAdd :: TextTagTableClass obj => obj -> TextTag -> IO ()
textTagTableAdd obj tag =
  {#call text_tag_table_add#} (toTextTagTable obj) tag

-- | Remove a tag from the table.
--
textTagTableRemove :: TextTagTableClass obj => obj -> TextTag -> IO ()
textTagTableRemove obj tag =
  {#call text_tag_table_remove#} (toTextTagTable obj) tag

-- | Look up a named tag.
--
textTagTableLookup :: TextTagTableClass obj => obj
                   -> String -> IO (Maybe TextTag)
textTagTableLookup obj name =
  withCString name $ \strPtr -> do
  tagPtr <- {#call unsafe text_tag_table_lookup#} (toTextTagTable obj) strPtr
  if tagPtr == nullPtr then return Nothing else liftM Just $
    makeNewGObject mkTextTag (return tagPtr)

-- | Calls func on each tag in table.
--
textTagTableForeach :: TextTagTableClass obj => obj
                    -> (TextTag -> IO ()) -> IO ()
textTagTableForeach obj func = do
  funcPtr <- mkTextTagTableForeach (\tagPtr _ -> do
    tag <- makeNewGObject mkTextTag (return tagPtr)
    func tag)
  {#call text_tag_table_foreach#} (toTextTagTable obj) funcPtr nullPtr

{#pointer TextTagTableForeach#}

foreign import ccall "wrapper" mkTextTagTableForeach ::
  (Ptr TextTag -> Ptr () -> IO ()) -> IO TextTagTableForeach

-- | Returns the size of the table (the number of tags).
--
textTagTableGetSize :: TextTagTableClass obj => obj -> IO Int
textTagTableGetSize obj = liftM fromIntegral $
  {#call unsafe text_tag_table_get_size#} (toTextTagTable obj)
