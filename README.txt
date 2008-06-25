Order 1.0 for Movable Type

Collect sets of template output to order by a particular datum.


INSTALLATION

Unarchive into your Movable Type directory.


USAGE

Use the provided template tags to collect and reorder template content. For
example:

    <mt:Order>

        <mt:Entries>
            <mt:OrderItem>
                <mt:setvarblock name="order_by">
                    <mt:EntryDate utc="1" format="%Y%m%d%H%M%S">
                </mt:setvarblock>
                <mt:Include module="Entry">
            </mt:OrderItem>
        </mt:Entries>

        <mt:Comments>
            <mt:OrderItem>
                <mt:setvarblock name="order_by">
                    <mt:CommentDate utc="1" format="%Y%m%d%H%M%S">
                </mt:setvarblock>
                <mt:Include module="Comment">
            </mt:OrderItem>
        </mt:Comments>
    
    </mt:Order>


LICENSE

Copyright 2008 Six Apart, Ltd.
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
