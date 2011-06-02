# Order 1.2 for Movable Type #

Collect sets of template output to order by a particular datum.


# Installation #

Unarchive into your Movable Type directory.


# Usage #

Use the provided template tags to collect and reorder template content. For
example, to show the last 30 unique entries and ActionStreams items:

    <mt:Order limit="30">

        <mt:OrderHeader>
            <div class="site-activity">
        </mt:OrderHeader>

        <mt:OrderDateHeader>
            <div id="one_day">	
                <p class="date"><mt:OrderDate utc="1" format="%B %e, %Y"></p>
        </mt:OrderDateHeader>

        <mt:OrderDateFooter>
            </div>
        </mt:OrderDateFooter>

        <mt:Entries lastn="30">
            <mt:OrderItem>
                <mt:setvarblock name="order_by" strip_linefeeds="1" trim="1">
                    <mt:EntryDate utc="1" format="%Y%m%d%H%M%S">
                </mt:setvarblock>
                <mt:Include module="Entry">
            </mt:OrderItem>
        </mt:Entries>

        <mt:ActionStreams limit="30">
            <mt:setvarblock name="actionurl"><mt:StreamActionURL escape="html"></mt:setvarblock>
            <mt:If name="actionurl" like="mysite.com">
            <mt:Else>
                <mt:OrderItem>
                    <mt:setvarblock name="order_by" strip_linefeeds="1" trim="1">
                        <$mt:StreamActionDate format="%Y%m%d%H%M%S"$>
                    </mt:setvarblock>
                    <p><a href="<mt:StreamActionURL escape="html">"><img src="/img/icons/<mt:var name="service_type">_16.png" width="12" height="12"></a> <a href="<mt:StreamActionURL escape="html">" class="actionlink"><mt:StreamActionTitle></a></p>
                </mt:OrderItem>
            </mt:If>
        </mt:ActionStreams>

        <mt:OrderFooter>
            </div>
        </mt:OrderFooter>

    </mt:Order>


# Template tags #

The collection and reordering of content is governed through these provided
template tags:


## mt:Order ##

Provides the context in which content items are reordered. All the
`mt:OrderItem` tags contained within an `mt:Order` tag are sorted as one set
of content based on the value of their `order_by` variables.

`mt:Order` takes the following optional attributes:

### `sort_order` ###

If set to `ascend`, reorders the content from first to last (that is, 1 to 9
and A to Z). Otherwise, the items are sorted in descending order (Z to A and 9
to 1).

### `offset` ###

Specifies a number of `mt:OrderItem`s to skip. That is, after reordering all
the `mt:OrderItem` tags, discard this many items from the front of the list.

### `limit` ###

Specifies how many `mt:OrderItem`s to show. That is, after reordering all the
`mt:OrderItem` tags (and discarding items due to `offset`), keep only this
many items from the front of the list.

### `natural` ###

If set to `1`, sorting values that look like numbers will be sorted
numerically. Otherwise, items are sorted "asciibetically."

When all your sorting values are strings of the same length that you want to
compare strictly character by character, such as timestamps, omit this to save
some computational work. If your content's sorting values are user-provided or
if they're numbers, specify `natural="1"`.

### `shuffle` ###

If set to `1`, reorder the items randomly instead of using the sorting values.

When using this attribute, you can safely omit the `natural`, `sort_order`,
and `by` attributes, and you need not set sorting values inside your
`mt:OrderItem` tags. `mt:OrderItem pin` attributes are still honored, however.

### `by` ###

Specifies the name of the variable by which to order items. If not given, the
items are sorted by the values of the default variable `order_by`.

If your `mt:OrderItem` template fragments are already storing their sorting
values in a variable, you can put the name of that variable in the `mt:Order
by` attribute to avoid copying those values into the `order_by` variable.


## `mt:OrderItem` ##

Packages a content fragment for reordering against the sibling `mt:OrderItem`
tags in an `mt:Order`.

Order items are reordered based on the value of the `order_by` variable you
set inside the `mt:OrderItem` tag. Set the `order_by` variable by using the
`mt:SetVarBlock` tag or the `setvar="variable name"` global attribute on a tag
inside the `mt:OrderItem`.

`mt:OrderItem` has two optional attributes:

### `pin` ###

When specified, instead of being sorted against the other items, the content
of the `mt:OrderItem` will be inserted into the ordered set at the point you
specify.

Pin points are zero-based indexes into the final set. That is, writing
`mt:OrderItem pin="0"` is almost like using the `mt:OrderHeader` tag. Pin
points can also be specified relative to the *end* of the list by using
negative numbers: writing `mt:OrderItem pin="-1"` is almost like using the
`mt:OrderFooter` tag.

If multiple `mt:OrderItem`s have the same `pin` value, those items will be
reordered based on their `order_by` values, then spliced into the full set of
items at the specified `pin` point as a contiguous tranche. Pinned groups are
inserted from left to right (`0` to `-1`), so groups with multiple items may
overlap with groups pinned nearby. For example, if there are four items pinned
at `0` and one item pinned at `1`, in the final reckoning three of the items
pinned at `0` will appear *after* the item at `1`: by the time the item at `1`
is finally pinned, the other items pinned at `0` have already become items 1,
2, and 3.

Pinned items are put in position *before* the `mt:Order` tag's `limit`
attribute is considered. That is, if you order 11 items, pin one to `-1`
(last), and use `limit="10"` on the `mt:Order` tag, the pinned item will *not*
be shown (it was the eleventh of ten items).


## `mt:OrderHeader` ##

Contains template content that is displayed at the front of the `mt:Order`
loop, as long as there are `mt:OrderItem`s to display.

Content from an `mt:OrderHeader` is shown before the first `mt:OrderItem`, or
even an `mt:OrderItem` pinned to the front with the `pin="0"` attribute.


## `mt:OrderFooter` ##

Contains template content that is displayed at the end of the `mt:Order` loop,
as long as there are `mt:OrderItem`s to display.

Content from an `mt:OrderFooter` is shown after the last `mt:OrderItem`,
even an `mt:OrderItem` pinned to the end with the `pin="-1"` attribute.


## `mt:OrderDateHeader` ##

A container tag whose contents will be displayed before the `mt:OrderItem` in context
if it is the first item for a given day. Requires `order_by` variable set inside the 
`mt:OrderItem` tag to be a timestamp formatted `%Y%m%d%H%M%S`.


## `mt:OrderDateFooter` ##

A container tag whose contents will be displayed after the `mt:OrderItem` in context
if it is the last item for a given day. Requires `order_by` variable set inside the 
`mt:OrderItem` tag to be a timestamp formatted `%Y%m%d%H%M%S`.


## `mt:OrderDate` ##

A function tag that works like an `mt:Date` tag, for use within `mt:OrderDateHeader`
and `mt:OrderDateFooter` blocks.


# Changes #

## 1.2 10 May 2011 ##

* Added `mt:OrderDateHeader` and `mt:OrderDateFooter` tags.
* Added `mt:OrderDate` tag.
* Added `unique` ordering option.


## 1.1  10 June 2010 ##

* Added `mt:OrderHeader` and `mt:OrderFooter` tags.
* Added `shuffle` ordering option.
* Added `pin` feature.

## 1.0  30 July 2008 ##

* First release


# License #

Copyright 2008-2009 Six Apart, Ltd.
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this
  list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright notice,
  this list of conditions and the following disclaimer in the documentation
  and/or other materials provided with the distribution.

* Neither the name of the Six Apart, Ltd. nor the names of its contributors
  may be used to endorse or promote products derived from this software
  without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
