// This file Copyright © Transmission authors and contributors.
// It may be used under the MIT (SPDX: MIT) license.
// License text can be found in the licenses/ folder.

#import "GroupToolbarItem.h"

@implementation GroupToolbarItem

- (void)applyStateToControl
{
    if (![self.view isKindOfClass:[NSControl class]])
    {
        return;
    }

    NSControl* control = (NSControl*)self.view;
    control.target = self.target;
    control.action = self.action;
    control.enabled = self.enabled;
}

- (void)setView:(NSView*)view
{
    [super setView:view];
    [self applyStateToControl];
}

- (void)setTarget:(id)target
{
    [super setTarget:target];
    [self applyStateToControl];
}

- (void)setAction:(SEL)action
{
    [super setAction:action];
    [self applyStateToControl];
}

- (void)setEnabled:(BOOL)enabled
{
    [super setEnabled:enabled];
    [self applyStateToControl];
}

- (void)validate
{
    NSSegmentedControl* control = (NSSegmentedControl*)self.view;

    NSInteger const count = self.subitems.count;
    for (NSInteger i = 0; i < count; i++)
    {
        NSToolbarItem* item = self.subitems[i];
        [control setEnabled:[self.target validateToolbarItem:item] forSegment:i];
    }
}

- (void)createMenu:(NSArray*)labels
{
    NSMenuItem* menuItem = [[NSMenuItem alloc] initWithTitle:self.label action:NULL keyEquivalent:@""];
    NSMenu* menu = [[NSMenu alloc] initWithTitle:self.label];
    menuItem.submenu = menu;

    menu.autoenablesItems = NO;

    NSInteger const count = self.subitems.count;
    for (NSInteger i = 0; i < count; i++)
    {
        NSMenuItem* addItem = [[NSMenuItem alloc] initWithTitle:labels[i] action:self.action keyEquivalent:@""];
        addItem.target = self.target;
        addItem.tag = i;

        [menu addItem:addItem];
    }

    self.menuFormRepresentation = menuItem;
}

- (NSMenuItem*)menuFormRepresentation
{
    NSMenuItem* menuItem = super.menuFormRepresentation;

    NSInteger const count = self.subitems.count;
    for (NSInteger i = 0; i < count; i++)
    {
        NSToolbarItem* item = self.subitems[i];
        [menuItem.submenu itemAtIndex:i].enabled = [self.target validateToolbarItem:item];
    }

    return menuItem;
}

@end
